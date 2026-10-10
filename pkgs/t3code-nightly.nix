# T3 Code desktop, nightly channel (prebuilt upstream AppImage).
#
# nixpkgs `t3code` tracks stable and is built from source (pnpm + Electron),
# so following nightly via an override would compile the whole app locally on
# every bump. This wraps the official nightly AppImage instead: download +
# FHS env, no compilation.
#
# What's inside the AppImage (verified 2026-09-06):
#   - Upstream's own t3code.desktop already passes --no-sandbox
#   - Resource-monitor sidecar is included (electron-builder artifact)
#   - No standalone `t3` server CLI; use `npx t3@latest` for that
#
# Update version + hash from the config root:
#   nix run nixpkgs#nix-update -- t3code-nightly --flake \
#     --version=unstable --version-regex 'v(.*-nightly\..*)' --build
# Then apply with `nh os switch`.
{
  lib,
  appimageTools,
  fetchurl,
  symlinkJoin,
  makeWrapper,
}: let
  pname = "t3code-nightly";
  # Full nightly version (date + build suffix); asset names use it verbatim.
  version = "0.0.46-nightly.20261006.2735";

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
    hash = "sha256-ocMS9u3tHYOEsgRDbsLNbNQra/L7N0mlKViXF6Yoglc=";
  };

  contents = appimageTools.extract {inherit pname version src;};

  fhs = appimageTools.wrapType2 {inherit pname version src;};
in
  symlinkJoin {
    name = "${pname}-${version}";
    paths = [fhs];
    nativeBuildInputs = [makeWrapper];

    # Let nix-update discover the upstream release and source hash.
    passthru = {inherit pname version src;};

    postBuild = ''
      # Upstream's desktop file already uses --no-sandbox (Nix store cannot
      # provide the setuid chrome-sandbox); make it the default for CLI use too.
      #
      # Force gnome-libsecret. Electron does not treat niri as a known DE, so
      # Chromium otherwise lands on basic_text. T3 then refuses to write
      # ~/.t3/userdata/connection-catalog.json ("Desktop secure storage is
      # unavailable in this system context") and Add Environment fails.
      # Passing this flag also matches T3's own niri/Hyprland heuristic
      # (pingdotgg/t3code#2916) instead of fighting it.
      #
      # Do not use --password-store=basic. A catalog written by one backend
      # cannot be decrypted by the other. If T3 hangs on "Still connecting
      # ... could not confirm this workspace", back up and delete
      # connection-catalog.json; the app recreates it. Threads/projects/
      # settings (sqlite + ~/.t3/userdata) are unrelated.
      wrapProgram "$out/bin/${pname}" \
        --add-flags "--no-sandbox" \
        --add-flags "--password-store=gnome-libsecret"

      # Drop-in for the nixpkgs stable binary name (keybinds/launchers keep working).
      ln -s "$out/bin/${pname}" "$out/bin/t3code-desktop"

      mkdir -p "$out/share/applications" "$out/share/icons/hicolor/256x256/apps"
      install -Dm444 "${contents}/t3code.desktop" "$out/share/applications/${pname}.desktop"
      substituteInPlace "$out/share/applications/${pname}.desktop" \
        --replace-fail "Exec=AppRun" "Exec=t3code-desktop" \
        --replace-fail "Icon=t3code" "Icon=${pname}"
      install -Dm444 "${contents}/usr/share/icons/hicolor/256x256/apps/t3code.png" \
        "$out/share/icons/hicolor/256x256/apps/${pname}.png"
    '';

    meta = {
      description = "T3 Code desktop app (nightly)";
      homepage = "https://t3.codes";
      downloadPage = "https://github.com/pingdotgg/t3code/releases";
      changelog = "https://github.com/pingdotgg/t3code/releases/tag/v${version}";
      license = lib.licenses.mit;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = ["x86_64-linux"];
      mainProgram = "t3code-desktop";
    };
  }
