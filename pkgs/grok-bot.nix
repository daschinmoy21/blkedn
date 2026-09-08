# Official linux-x64 Grok Bot .deb, wrapped for NixOS.
#
# x.ai/bot only lists macOS, Windows, and iOS. Cursor still publishes a Linux
# package at downloads.cursor.com; the linux-x64 update feed is empty (HTTP 204),
# so version + buildId come from the darwin/win32 sand feed.
#
# This follows androso/grokbot-linux (official .deb + --no-sandbox) rather than
# Nichokas/grokbot-linux-port (Windows NSIS fused with stock Electron).
#
# Refresh:
#   curl -sS https://api2.cursor.sh/updates/api/update/darwin-arm64/sand/0.0.0/stable
#   nix store prefetch-file --hash-type sha256 \
#     "https://downloads.cursor.com/grokbot/stable/<buildId>/linux/x64/Grok_Bot_<ver>.deb"
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeShellWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libGL,
  libglvnd,
  libnotify,
  libpulseaudio,
  libsecret,
  libuuid,
  libX11,
  libxcb,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libxkbcommon,
  libXrandr,
  libXrender,
  libXScrnSaver,
  libxshmfence,
  libXtst,
  nspr,
  nss,
  pango,
  systemd,
  vulkan-loader,
  wayland,
  xdg-utils,
}: let
  downloadBase = "https://downloads.cursor.com/grokbot/stable";
  buildId = "f0e5bfcee649ea84c0c61369cf896cd146d72136";

  runtimeLibs = [
    libglvnd
    libGL
    libgbm
    libdrm
    vulkan-loader
    wayland
    libxkbcommon
    libpulseaudio
    libsecret
    libnotify
    (lib.getLib systemd)
  ];
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "grok-bot";
    version = "0.29.0";

    src = fetchurl {
      url = "${downloadBase}/${buildId}/linux/x64/Grok_Bot_${finalAttrs.version}.deb";
      hash = "sha256-0iO1gwKCrvEdXEbY9NHt0jm/mS4zZAXL0ojUR2uSM9Q=";
    };

    nativeBuildInputs = [
      dpkg
      autoPatchelfHook
      makeShellWrapper
      wrapGAppsHook3
    ];

    buildInputs =
      [
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        cairo
        cups
        dbus
        expat
        fontconfig
        freetype
        gdk-pixbuf
        glib
        gtk3
        libuuid
        nspr
        nss
        pango
        stdenv.cc.cc.lib
        libX11
        libxcb
        libXcomposite
        libXcursor
        libXdamage
        libXext
        libXfixes
        libXi
        libXrandr
        libXrender
        libXScrnSaver
        libxshmfence
        libXtst
      ]
      ++ runtimeLibs;

    runtimeDependencies = runtimeLibs;

    dontStrip = true;
    dontWrapGApps = true;

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x "$src" .
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/grok-bot"
      cp -r "opt/Grok Bot/." "$out/share/grok-bot/"

      # chrome-sandbox only works setuid root. The Nix store cannot express that.
      rm -f "$out/share/grok-bot/chrome-sandbox"

      mkdir -p "$out/share/icons"
      cp -r usr/share/icons/hicolor "$out/share/icons/"

      if [ -f usr/share/applications/grok-bot.desktop ]; then
        desktop=usr/share/applications/grok-bot.desktop
        desktopExec='"/opt/Grok Bot/grok-bot"'
      else
        desktop=usr/share/applications/sand.desktop
        desktopExec='"/opt/Grok Bot/sand"'
      fi
      install -Dm644 "$desktop" "$out/share/applications/grok-bot.desktop"
      substituteInPlace "$out/share/applications/grok-bot.desktop" \
        --replace-fail "$desktopExec" "$out/bin/grok-bot"
      sed -i 's/^Icon=.*/Icon=grok-bot/' \
        "$out/share/applications/grok-bot.desktop"

      runHook postInstall
    '';

    preFixup = ''
      # makeShellWrapper, not makeBinaryWrapper: the ozone flags need shell
      # expansion. wrapGAppsHook3 would otherwise pull in a binary wrapper.
      #
      # --no-sandbox is required. Upstream Electron crash-loops the Computer
      # <webview> (sandbox: true) with FATAL:platform_shared_memory_region_posix.cc.
      # Same bug on stock Ubuntu with the official .deb.
      #
      # Renderer backgrounding is off so agent notifications still fire when the
      # window is occluded (androso/grokbot-linux).
      if [ -x "$out/share/grok-bot/grok-bot" ]; then
        upstreamExecutable="$out/share/grok-bot/grok-bot"
      else
        upstreamExecutable="$out/share/grok-bot/sand"
      fi

      makeShellWrapper "$upstreamExecutable" "$out/bin/grok-bot" \
        "''${gappsWrapperArgs[@]}" \
        --suffix PATH : ${lib.makeBinPath [xdg-utils]} \
        --set-default CHROME_DESKTOP grok-bot.desktop \
        --add-flags "--no-sandbox" \
        --add-flags "--disable-renderer-backgrounding" \
        --add-flags "--disable-backgrounding-occluded-windows" \
        --add-flags "--disable-background-timer-throttling" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"

      ln -s "$out/bin/grok-bot" "$out/bin/sand"
    '';

    meta = {
      description = "Grok Bot desktop agent";
      homepage = "https://x.ai/bot";
      downloadPage = "https://cursor.com";
      license = lib.licenses.unfree;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = ["x86_64-linux"];
      mainProgram = "grok-bot";
    };
  })
