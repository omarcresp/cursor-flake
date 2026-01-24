{ pkgs, appimageTools, ... }:

let
  pname = "cursor";
  version = "2.4.21";
  downloadUrl = "https://downloads.cursor.com/production/dc8361355d709f306d5159635a677a571b277bcc/linux/x64/Cursor-2.4.21-x86_64.AppImage";

  inherit (pkgs.stdenvNoCC) hostPlatform stdenvNoCC;

  source = pkgs.fetchurl {
    url = downloadUrl;
    hash = "sha256-OOjANfVHMlRN1uWq2jNmK/RqI4Q5NTlN/19Nl2jWiKI=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit version pname;
    src = source;
  };

  wrappedAppimage = appimageTools.wrapType2 {
    inherit version pname;
    src = source;
  };

in
pkgs.stdenvNoCC.mkDerivation {
  inherit pname version;
  src = if hostPlatform.isLinux then wrappedAppimage else source;

  nativeBuildInputs =
    pkgs.lib.optionals hostPlatform.isLinux [ pkgs.makeWrapper ]
    ++ pkgs.lib.optionals hostPlatform.isDarwin [ pkgs.undmg ];

  sourceRoot = pkgs.lib.optionalString hostPlatform.isDarwin ".";
  dontUpdateAutotoolsGnuConfigScripts = hostPlatform.isDarwin;
  dontConfigure = hostPlatform.isDarwin;
  dontFixup = hostPlatform.isDarwin;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/

    ${
      if hostPlatform.isLinux then
        ''
          cp -r bin $out/bin
          mkdir -p $out/share/cursor
          cp -a ${appimageContents}/usr/share/cursor/locales $out/share/cursor
          cp -a ${appimageContents}/usr/share/cursor/resources $out/share/cursor
          cp -a ${appimageContents}/usr/share/icons $out/share/
          install -Dm 644 ${appimageContents}/cursor.desktop -t $out/share/applications/

          wrapProgram $out/bin/cursor \
            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}} --no-update"
        ''
      else
        ''
          APP_DIR="$out/Applications"
          CURSOR_APP="$APP_DIR/Cursor.app"
          mkdir -p "$APP_DIR"
          cp -Rp Cursor.app "$APP_DIR"
          mkdir -p "$out/bin"
          cat << EOF > "$out/bin/cursor"

          #!${stdenvNoCC.shell}
          open -na "$CURSOR_APP" --args "\$@"
          EOF
          chmod +x "$out/bin/cursor"
        ''
    }

    runHook postInstall
  '';
}
