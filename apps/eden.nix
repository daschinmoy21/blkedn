# Official Eden AppImage — download only, no CMake source build.
# Intel / generic x86_64 → amd64-clang-pgo (recommended PGO build).
# Launch via FHS + --appimage-extract-and-run (reliable on NixOS).
{
  pkgs,
  lib,
  ...
}: let
  version = "0.2.1";
  pname = "eden";

  src = pkgs.fetchurl {
    url = "https://stable.eden-emu.dev/v${version}/Eden-Linux-v${version}-amd64-clang-pgo.AppImage";
    hash = "sha256-TL3W6T4PKN+CA+6SoncuGXEFxLa+se39LKLDgyJt04A=";
    executable = true;
  };

  icon = pkgs.fetchurl {
    url = "https://git.eden-emu.dev/eden-emu/eden/raw/branch/master/dist/eden.icon/Assets/dev.eden_emu.eden.svg";
    hash = "sha256-XrRaJfrcYvw10SO0/hlGKw5///7X3T8Ukg5UMrOFl2k=";
  };

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    desktopName = "Eden";
    comment = "Nintendo Switch emulator";
    exec = "${pname} %f";
    icon = pname;
    categories = ["Game" "Emulator"];
    mimeTypes = [
      "application/x-nx-nro"
      "application/x-nx-nso"
      "application/x-nx-nsp"
      "application/x-nx-xci"
    ];
  };

  iconDrv = pkgs.runCommand "${pname}-icon" {} ''
    mkdir -p $out/share/icons/hicolor/scalable/apps
    cp ${icon} $out/share/icons/hicolor/scalable/apps/${pname}.svg
  '';

  eden = pkgs.symlinkJoin {
    name = "${pname}-${version}";
    paths = [
      (pkgs.buildFHSEnv {
        name = pname;
        targetPkgs = p:
          with p; [
            vulkan-loader
            wayland
            libGL
            mesa
            glib
            libx11
            libxext
            libxrandr
            libxi
            libxkbcommon
            fontconfig
            freetype
            alsa-lib
            pipewire
            libusb1
            udev
            zstd
            lz4
          ];
        runScript = pkgs.writeShellScript "${pname}-launch" ''
          exec ${src} --appimage-extract-and-run "$@"
        '';
      })
      desktopItem
      iconDrv
    ];
    meta = {
      description = "Nintendo Switch emulator (official amd64 PGO AppImage)";
      homepage = "https://eden-emu.dev/";
      downloadPage = "https://eden-emu.dev/download";
      license = lib.licenses.gpl3Plus;
      mainProgram = pname;
      platforms = ["x86_64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  };
in {
  home.packages = [eden];
}
