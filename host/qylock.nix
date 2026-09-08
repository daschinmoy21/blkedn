{
  pkgs,
  inputs,
  lib,
  ...
}: let
  theme = "pixel-hollowknight";

  # Upstream qylock-lock only suffixes QML import paths for qtmultimedia.
  # MediaPlayer also needs the ffmpeg/gstreamer *plugins* on QT_PLUGIN_PATH.
  # SDDM gets those via services.displayManager.sddm.extraPackages (login works);
  # session lock does not, so the UI shows but bg.mp4 stays black.
  # https://github.com/Darkkal44/qylock
  qylockLock = let
    base = inputs.qylock.legacyPackages.${pkgs.stdenv.hostPlatform.system}.mkQuickshell {
      defaultTheme = theme;
    };
  in
    pkgs.symlinkJoin {
      name = "qylock-lock-with-multimedia";
      paths = [base];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/qylock-lock \
          --prefix QT_PLUGIN_PATH : "${pkgs.qt6.qtmultimedia}/lib/qt-6/plugins" \
          --set-default QT_MEDIA_BACKEND ffmpeg
      '';
    };
in {
  # Same theme for:
  #   - SDDM login (boot / logout)  → programs.qylock.sddm
  #   - session lock (Mod+Alt+L)    → qylock-lock (quickshell)
  programs.qylock = {
    enable = true;
    theme = theme;
    sddm.enable = true;
    # Install our re-wrapped binary instead (same theme + media plugins)
    quickshell.enable = false;
  };

  environment.systemPackages = [qylockLock];
}
