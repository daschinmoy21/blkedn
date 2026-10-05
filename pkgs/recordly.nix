# Recordly screen recorder/editor (prebuilt upstream AppImage).
# Modeled on pkgs/tldraw-offline.nix.
#
# Bump: pick the newest tag at https://github.com/webadderall/Recordly/releases,
#   nix store prefetch-file --hash-type sha256 <AppImage url>
# then update `version` + `hash`.
{
  lib,
  appimageTools,
  fetchurl,
  symlinkJoin,
  makeWrapper,
}: let
  pname = "recordly";
  version = "1.4.0";

  src = fetchurl {
    url = "https://github.com/webadderall/Recordly/releases/download/v${version}/Recordly-linux-x64.AppImage";
    hash = "sha256-N7FsQW7plw4BF6mDmr4LfgJPPwLbdn8aYSJSi4RwSkE=";
  };

  contents = appimageTools.extract {inherit pname version src;};

  fhs = appimageTools.wrapType2 {inherit pname version src;};
in
  symlinkJoin {
    name = "${pname}-${version}";
    paths = [fhs];
    nativeBuildInputs = [makeWrapper];

    postBuild = ''
      wrapProgram "$out/bin/${pname}" --add-flags "--no-sandbox"

      mkdir -p "$out/share/applications"
      install -Dm444 "$(ls ${contents}/*.desktop | head -1)" "$out/share/applications/${pname}.desktop"
      sed -i "s|^Exec=.*|Exec=${pname} %U|" "$out/share/applications/${pname}.desktop"

      if [ -d "${contents}/usr/share/icons/hicolor" ]; then
        mkdir -p "$out/share/icons"
        cp -r "${contents}/usr/share/icons/hicolor" "$out/share/icons/"
      fi
    '';

    meta = {
      description = "Screen recorder and editor";
      homepage = "https://github.com/webadderall/Recordly";
      license = lib.licenses.unfree;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = ["x86_64-linux"];
      mainProgram = "recordly";
    };
  }
