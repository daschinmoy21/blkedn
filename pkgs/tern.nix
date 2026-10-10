# Tern CLI (prebuilt upstream binary, from a locally downloaded tarball).
#
# The tarball is not fetchable, so it is a requireFile. Add it to the store
# once (and again for each new version) with:
#   nix store add-file --name Tern-<version>-linux-x86_64.tar.gz \
#     ~/Tern-<version>-linux-x86_64.tar.gz
# then update `version` + `hash` below (`nix hash file --sri <tarball>`).
#
# Patched in place with autoPatchelfHook; dontStrip because stripping can
# corrupt binaries that carry an embedded payload.
{
  lib,
  stdenv,
  requireFile,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  glib,
  libxcb,
  libxkbcommon,
  wayland,
  vulkan-loader,
  libGL,
  pam,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
}:
stdenv.mkDerivation rec {
  pname = "tern";
  version = "0.5.3";

  src = requireFile {
    name = "Tern-${version}-linux-x86_64.tar.gz";
    hash = "sha256-ROZMeGXsA/OQU6mhwNsUSXjhFiiH4v99WJQiDxD2mSw=";
    message = ''
      Add the tarball to the store:
        nix store add-file --name Tern-${version}-linux-x86_64.tar.gz ~/Tern-${version}-linux-x86_64.tar.gz
    '';
  };

  sourceRoot = ".";
  nativeBuildInputs = [autoPatchelfHook makeWrapper copyDesktopItems];
  buildInputs = [stdenv.cc.cc.lib];
  dontStrip = true;

  # Loaded with dlopen at runtime (GPU window: X11/Wayland, Vulkan/EGL, PAM),
  # so they are not in NEEDED; runtimeDependencies puts them on the RPATH.
  runtimeDependencies = [
    libxcb
    libxkbcommon
    wayland
    vulkan-loader
    libGL
    pam
    libx11
    libxcursor
    libxi
    libxrandr
  ];

  # The tarball ships only the binary (no .desktop file or icon), so provide a launcher entry.
  desktopItems = [
    (makeDesktopItem {
      name = "tern";
      desktopName = "Tern";
      comment = "Tern";
      exec = "tern";
      icon = "utilities-terminal";
      terminal = false;
      categories = ["Development"];
    })
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 tern/tern $out/bin/tern
    # gdbus is used for the desktop settings portal (dark mode, etc.).
    wrapProgram $out/bin/tern --prefix PATH : ${lib.makeBinPath [glib]}
    runHook postInstall
  '';

  meta = {
    description = "Tern CLI";
    license = lib.licenses.unfree;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    platforms = ["x86_64-linux"];
    mainProgram = "tern";
  };
}
