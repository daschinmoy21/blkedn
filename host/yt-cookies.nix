# Daily YouTube cookie dump: Helium CDP -> rsync to netcup.
# Helium wrap (localhost :9222) lives in pkgs/helium-cdp.nix, used from programs.nix.
# Script: tools/sync-yt-cookies/sync-yt-cookies.py
# Remote: netcup:~/stack/music/re-command-scripts/secrets/youtube.cookies.txt
# Failures pop a critical Noctalia notification (org.freedesktop.Notifications).
{
  pkgs,
  lib,
  ...
}: let
  python = pkgs.python3.withPackages (ps: [ps.websocket-client]);
  sync-yt-cookies = pkgs.writeShellApplication {
    name = "sync-yt-cookies";
    runtimeInputs = [
      python
      pkgs.rsync
      pkgs.openssh
      pkgs.coreutils
    ];
    text = ''
      exec python3 ${../tools/sync-yt-cookies/sync-yt-cookies.py} "$@"
    '';
  };
  sync-yt-cookies-notify = pkgs.writeShellApplication {
    name = "sync-yt-cookies-notify";
    runtimeInputs = [
      pkgs.libnotify
      pkgs.systemd
      pkgs.coreutils
    ];
    text = builtins.readFile ../tools/sync-yt-cookies/notify.sh;
  };
in {
  environment.systemPackages = [sync-yt-cookies];

  systemd.user.services.sync-yt-cookies = {
    description = "Dump Helium YouTube cookies and rsync to netcup";
    after = ["graphical-session.target"];
    onFailure = ["sync-yt-cookies-notify.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe sync-yt-cookies;
    };
  };

  systemd.user.services.sync-yt-cookies-notify = {
    description = "Notify when YouTube cookie sync fails";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe sync-yt-cookies-notify;
    };
  };

  systemd.user.timers.sync-yt-cookies = {
    description = "Refresh YouTube cookies on netcup once a day";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      Unit = "sync-yt-cookies.service";
    };
  };
}
