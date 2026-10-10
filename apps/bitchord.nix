# BitChord (YouTube Music client) — the daschinmoy21/BitChord fork, installed from the AppImage its
# GitHub Actions build publishes.
#
# The AppImage is the `bitchord-appimage` flake input (see flake.nix), so the rebuild itself downloads
# it and puts it in the store; nothing is fetched when the app is run. flake.lock pins the exact build,
# and a newer one is picked up at rebuild time:
#
#   build    = nh os switch -U bitchord-appimage <flake>   (rebuild, taking the newest BitChord build)
#   update   = nh os switch -u -a <flake>                  (rebuild with every input updated)
#
# Plain `nh os switch` rebuilds with the build that is locked. Wrapped the way pkgs/recordly.nix wraps
# its AppImage (appimageTools.wrapType2), so it runs in an FHS environment.
#
# The AppImage's own launcher sets _JAVA_AWT_WM_NONREPARENTING on Wayland, which is what lets the
# window follow tiling resizes under niri's xwayland-satellite.
{
  pkgs,
  lib,
  inputs,
  ...
}: let
  pname = "bitchord";
  # The build is identified by its content in flake.lock rather than by a version number.
  version = "fork";

  bitchord = pkgs.appimageTools.wrapType2 {
    inherit pname version;
    src = inputs.bitchord-appimage;
    meta = {
      description = "YouTube Music client with Navidrome support (daschinmoy21 fork)";
      homepage = "https://github.com/daschinmoy21/BitChord";
      license = lib.licenses.unfree;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = ["x86_64-linux"];
      mainProgram = pname;
    };
  };

  icon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/daschinmoy21/BitChord/50421d2da0c734969dd7c5cbb541bbc71ad9116a/desktopApp/packaging/icons/AppIcon.png";
    hash = "sha256-mxWL4dWm+TUKki6P56HdzPhw82YFiXFgz1Gz0YTxxM8=";
  };
in {
  home.packages = [bitchord];

  xdg.desktopEntries.bitchord = {
    name = "BitChord";
    genericName = "Music Player";
    comment = "YouTube Music client with Navidrome support";
    exec = "bitchord";
    icon = "${icon}";
    terminal = false;
    categories = ["AudioVideo" "Audio" "Player"];
    settings.StartupWMClass = "com-music-bitchord-desktop-MainKt";
  };
}
