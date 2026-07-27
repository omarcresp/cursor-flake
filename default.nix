{
  pkgs,
  appimageTools,
  lib,
  ...
}:

let
  pname = "cursor";
  inherit (pkgs.stdenvNoCC) hostPlatform stdenvNoCC;

  release = lib.importJSON ./sources.json;
  inherit (release) version;
  sourceInfo =
    release.sources.${hostPlatform.system}
      or (throw "cursor: unsupported platform ${hostPlatform.system}");
  source = pkgs.fetchurl sourceInfo;

  appimageContents = appimageTools.extractType2 {
    inherit version pname;
    src = source;
  };

  wrappedAppimage = appimageTools.wrapType2 {
    inherit version pname;
    src = source;
    extraPkgs = pkgs: [ pkgs.libxkbfile ];
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

          # The extracted icons are named `cursor.png`, but the upstream desktop
          # entry references `Icon=co.anysphere.cursor`, so icon-theme lookup fails
          # and no icon shows. Point the desktop entry at the actual icon name.
          substituteInPlace $out/share/applications/cursor.desktop \
            --replace-quiet "Icon=co.anysphere.cursor" "Icon=cursor"

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
          ln -s "$CURSOR_APP/Contents/Resources/app/bin/cursor" "$out/bin/cursor"
        ''
    }

    runHook postInstall
  '';

  meta = {
    description = "AI-powered code editor built on VS Code";
    homepage = "https://cursor.com";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames release.sources;
    mainProgram = "cursor";
  };
}
