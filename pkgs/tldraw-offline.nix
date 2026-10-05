# tldraw offline desktop (prebuilt upstream AppImage).
#
# Upstream publishes a Linux AppImage per release; wrapping it avoids any
# local build. Modeled on pkgs/t3code-nightly.nix (appimageTools.wrapType2 +
# symlinkJoin, --no-sandbox forced since the Nix store cannot carry the
# setuid chrome-sandbox).
#
# Bump:
#   1. Pick the newest tag at https://github.com/tldraw/tldraw-offline/releases
#   2. nix store prefetch-file --hash-type sha256 \
#        "https://github.com/tldraw/tldraw-offline/releases/download/<tag>/tldraw-offline-linux-x86_64.AppImage"
#   3. Update `version` + `hash` below and rebuild.
{
  lib,
  appimageTools,
  fetchurl,
  symlinkJoin,
  makeWrapper,
}: let
  pname = "tldraw-offline";
  version = "1.16.0";

  src = fetchurl {
    url = "https://github.com/tldraw/tldraw-offline/releases/download/v${version}/tldraw-offline-linux-x86_64.AppImage";
    hash = "sha256-YNW0Hk6UhLS6IpghqJhOkXVjkuDgEaPhtCf3Fwo7r9g=";
  };

  contents = appimageTools.extract {inherit pname version src;};

  fhs = appimageTools.wrapType2 {inherit pname version src;};
in
  symlinkJoin {
    name = "${pname}-${version}";
    paths = [fhs];
    nativeBuildInputs = [makeWrapper];

    postBuild = ''
      # Nix store cannot provide the setuid chrome-sandbox, so always run
      # unsandboxed (same as grok-bot / t3code-nightly wrappers).
      wrapProgram "$out/bin/${pname}" \
        --add-flags "--no-sandbox"

      mkdir -p "$out/share/applications"
      install -Dm444 "${contents}/tldraw-offline.desktop" "$out/share/applications/${pname}.desktop"
      substituteInPlace "$out/share/applications/${pname}.desktop" \
        --replace-fail "Exec=AppRun" "Exec=${pname}"

      mkdir -p "$out/share/icons"
      cp -r "${contents}/usr/share/icons/hicolor" "$out/share/icons/"

      mkdir -p "$out/share/mime/packages"
      install -Dm444 "${contents}/usr/share/mime/packages/tldraw-offline.xml" \
        "$out/share/mime/packages/tldraw-offline.xml"
    '';

    meta = {
      description = "tldraw offline desktop app";
      homepage = "https://tldraw.com";
      downloadPage = "https://github.com/tldraw/tldraw-offline/releases";
      changelog = "https://github.com/tldraw/tldraw-offline/releases/tag/v${version}";
      license = lib.licenses.unfree;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = ["x86_64-linux"];
      mainProgram = "tldraw-offline";
    };
  }
