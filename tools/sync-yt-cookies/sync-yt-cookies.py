#!/usr/bin/env python3
"""Dump decrypted YouTube cookies from Helium CDP and rsync them to netcup."""

from __future__ import annotations

import argparse
import json
import os
import ssl
import stat
import subprocess
import sys
import tempfile
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any

import websocket

LOGIN_NAMES = frozenset(
    {
        "SID",
        "SAPISID",
        "LOGIN_INFO",
        "__Secure-1PSID",
        "__Secure-3PSID",
    }
)
KEEP_SUFFIXES = (
    "youtube.com",
    "youtu.be",
    "youtube-nocookie.com",
    "google.com",
)
DEFAULT_PORT = 9222
DEFAULT_REMOTE = (
    "netcup:~/stack/music/re-command-scripts/secrets/youtube.cookies.txt"
)
HELIUM_DEVTOOLS_PORT_FILE = Path.home() / ".config/net.imput.helium/DevToolsActivePort"


def die(msg: str, code: int = 1) -> None:
    print(msg, file=sys.stderr)
    raise SystemExit(code)


def keep_domain(domain: str) -> bool:
    host = domain.lstrip(".").lower()
    return any(host == s or host.endswith("." + s) for s in KEEP_SUFFIXES)


def state_dir() -> Path:
    raw = os.environ.get("XDG_STATE_HOME")
    root = Path(raw) if raw else Path.home() / ".local/state"
    path = root / "yt-cookies"
    path.mkdir(mode=0o700, parents=True, exist_ok=True)
    os.chmod(path, 0o700)
    return path


def http_json(url: str, timeout: float = 3.0) -> Any:
    with urllib.request.urlopen(url, timeout=timeout) as resp:
        return json.loads(resp.read().decode())


def rewrite_ws_url(ws_url: str, host: str, port: int) -> str:
    """Helium builds webSocketDebuggerUrl from the HTTP Host header.

    A Host without :port makes Chrome omit 9222, so the client hits :80 and
    gets connection refused. Always pin host:port to the socket we already
    reached over HTTP.
    """
    parsed = urllib.parse.urlparse(ws_url)
    return parsed._replace(netloc=f"{host}:{port}").geturl()


def read_devtools_port() -> int | None:
    try:
        first = HELIUM_DEVTOOLS_PORT_FILE.read_text().splitlines()[0].strip()
        port = int(first)
        if 1 <= port <= 65535:
            return port
    except (OSError, ValueError, IndexError):
        return None
    return None


def cdp_call(ws: websocket.WebSocket, method: str, params: dict | None = None) -> dict:
    payload: dict[str, Any] = {"id": 1, "method": method}
    if params:
        payload["params"] = params
    ws.send(json.dumps(payload))
    while True:
        raw = ws.recv()
        data = json.loads(raw)
        if data.get("id") != 1:
            continue
        if "error" in data:
            raise RuntimeError(f"{method}: {data['error']}")
        result = data.get("result")
        if not isinstance(result, dict):
            raise RuntimeError(f"{method}: empty result")
        return result


def cookies_from_ws(url: str, origin: str) -> list[dict]:
    ws = websocket.create_connection(
        url,
        timeout=10,
        origin=origin,
        sslopt={"cert_reqs": ssl.CERT_NONE},
    )
    try:
        for method in ("Storage.getCookies", "Network.getAllCookies"):
            try:
                result = cdp_call(ws, method)
            except RuntimeError:
                continue
            cookies = result.get("cookies")
            if isinstance(cookies, list) and cookies:
                return cookies
        raise RuntimeError("no cookies from Storage.getCookies / Network.getAllCookies")
    finally:
        ws.close()
    return []


def candidate_ws_urls(host: str, port: int) -> list[str]:
    origin = f"http://{host}:{port}"
    urls: list[str] = []
    try:
        version = http_json(f"{origin}/json/version")
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError) as e:
        raise OSError(
            "Helium CDP not reachable at "
            f"{host}:{port} ({e}). "
            "Quit Helium and open it again so it picks up the localhost debug port."
        ) from e
    browser = version.get("webSocketDebuggerUrl")
    if browser:
        urls.append(rewrite_ws_url(str(browser), host, port))
    try:
        tabs = http_json(f"{origin}/json/list")
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError):
        tabs = []
    if isinstance(tabs, list):
        for tab in tabs:
            if not isinstance(tab, dict):
                continue
            if tab.get("type") not in ("page", "iframe"):
                continue
            ws = tab.get("webSocketDebuggerUrl")
            if ws:
                urls.append(rewrite_ws_url(str(ws), host, port))
    # Unique, browser target first.
    seen: set[str] = set()
    out: list[str] = []
    for url in urls:
        if url not in seen:
            seen.add(url)
            out.append(url)
    return out


def dump_cookies(host: str, port: int) -> list[dict]:
    origin = f"http://{host}:{port}"
    urls = candidate_ws_urls(host, port)
    if not urls:
        die(f"{origin}/json/version had no webSocketDebuggerUrl")
    last_err: Exception | None = None
    cookies: list[dict] = []
    for ws_url in urls:
        try:
            cookies = cookies_from_ws(ws_url, origin)
            break
        except Exception as e:
            last_err = e
            continue
    else:
        die(
            "CDP websocket failed on every target: "
            f"{type(last_err).__name__}: {last_err}"
        )
    kept = [c for c in cookies if keep_domain(str(c.get("domain") or ""))]
    if not kept:
        die("CDP had cookies, but none were youtube.com / google.com")
    return kept


def netscape_lines(cookies: list[dict]) -> list[str]:
    lines = [
        "# Netscape HTTP Cookie File",
        "# This file is generated by sync-yt-cookies. Do not edit.",
        "",
    ]
    for c in cookies:
        name = str(c.get("name") or "")
        value = str(c.get("value") or "")
        domain = str(c.get("domain") or "")
        path = str(c.get("path") or "/")
        if not name or not domain or "\t" in name or "\t" in value:
            continue
        secure = "TRUE" if c.get("secure") else "FALSE"
        expires = c.get("expires")
        try:
            exp = int(float(expires)) if expires is not None else 0
        except (TypeError, ValueError):
            exp = 0
        if exp < 0:
            exp = 0
        flag = "TRUE" if domain.startswith(".") else "FALSE"
        host = domain
        if c.get("httpOnly"):
            host = "#HttpOnly_" + domain
        lines.append(f"{host}\t{flag}\t{path}\t{secure}\t{exp}\t{name}\t{value}")
    return lines


def login_ok(cookies: list[dict]) -> bool:
    names = {str(c.get("name") or "") for c in cookies}
    return bool(names & LOGIN_NAMES)


def write_atomic(path: Path, text: str) -> None:
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix=".cookies.", dir=str(path.parent), text=True)
    try:
        with os.fdopen(fd, "w") as f:
            f.write(text)
            if not text.endswith("\n"):
                f.write("\n")
        os.chmod(tmp, stat.S_IRUSR | stat.S_IWUSR)
        os.replace(tmp, path)
        os.chmod(path, stat.S_IRUSR | stat.S_IWUSR)
    finally:
        if os.path.exists(tmp):
            try:
                os.remove(tmp)
            except OSError:
                pass


def summarize(cookies: list[dict]) -> str:
    yt = sum(1 for c in cookies if "youtube" in str(c.get("domain") or "").lower())
    g = sum(1 for c in cookies if "google" in str(c.get("domain") or "").lower())
    login = "yes" if login_ok(cookies) else "NO"
    return f"{len(cookies)} cookies (youtube={yt} google={g} login={login})"


def rsync_jar(local: Path, remote: str) -> None:
    cmd = [
        "rsync",
        "-az",
        "--chmod=F600",
        "-e",
        "ssh -o BatchMode=yes -o ConnectTimeout=10",
        str(local),
        remote,
    ]
    try:
        subprocess.run(cmd, check=True)
    except FileNotFoundError:
        die("rsync not on PATH")
    except subprocess.CalledProcessError as e:
        die(f"rsync to {remote} failed (exit {e.returncode})")


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument(
        "--dry-run",
        action="store_true",
        help="write the local jar only, skip rsync",
    )
    p.add_argument("--port", type=int, default=DEFAULT_PORT)
    p.add_argument("--host", default="127.0.0.1")
    p.add_argument(
        "--remote",
        default=os.environ.get("YT_COOKIES_REMOTE", DEFAULT_REMOTE),
    )
    p.add_argument(
        "--out",
        default=None,
        help="local Netscape path (default: $XDG_STATE_HOME/yt-cookies/youtube.cookies.txt)",
    )
    return p.parse_args()


def main() -> None:
    args = parse_args()
    port = args.port
    if port == DEFAULT_PORT:
        discovered = read_devtools_port()
        if discovered and discovered != DEFAULT_PORT:
            print(
                f"DevToolsActivePort is {discovered}, trying that after {DEFAULT_PORT} if needed",
                file=sys.stderr,
            )
    try:
        cookies = dump_cookies(args.host, port)
    except OSError as e:
        discovered = read_devtools_port() if port == DEFAULT_PORT else None
        if discovered and discovered != port:
            print(f"{e}\nretrying on DevToolsActivePort {discovered}", file=sys.stderr)
            cookies = dump_cookies(args.host, discovered)
        else:
            die(str(e))
    if not login_ok(cookies):
        die(
            "refusing to upload: jar has no SID / SAPISID / LOGIN_INFO / __Secure-1PSID. "
            "Log into YouTube in Helium, then retry."
        )
    out = Path(args.out) if args.out else state_dir() / "youtube.cookies.txt"
    write_atomic(out, "\n".join(netscape_lines(cookies)))
    print(f"dumped {summarize(cookies)}")
    print(f"wrote {out} ({out.stat().st_size} bytes)")
    if args.dry_run:
        print("dry-run: skipped rsync")
        return
    rsync_jar(out, args.remote)
    print(f"rsync {args.remote} ok")


if __name__ == "__main__":
    main()
