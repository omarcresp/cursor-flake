{ pkgs, appimageTools, ... }:

let
  pname = "cursor";
  version = "0.40.4";
  appKey = "230313mzl4w4u92";
  buildKey = "2409052yfcjagw2";

  src = pkgs.fetchurl {
    url = "https://download.todesktop.com/${appKey}/cursor-${version}-build-${buildKey}-x86_64.AppImage";
    hash = "sha256-ZURE8UoLPw+Qo1e4xuwXgc+JSwGrgb/6nfIGXMacmSg=";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-quiet 'Exec=AppRun' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share

    if [ -e ${appimageContents}/AppRun ]; then
      install -m 755 -D ${appimageContents}/AppRun $out/bin/${pname}-${version}
      if [ ! -L $out/bin/${pname} ]; then
        ln -s $out/bin/${pname}-${version} $out/bin/${pname}
      fi
    else
      echo "Error: Binary not found in extracted AppImage contents."
      exit 1
    fi
  '';

  extraBwrapArgs = [
    "--bind-try /etc/nixos/ /etc/nixos/"
  ];

  dieWithParent = false;

  extraPkgs = pkgs: with pkgs; [
    unzip
    autoPatchelfHook
    asar
    (buildPackages.wrapGAppsHook.override { inherit (buildPackages) makeWrapper; })
  ];
}
