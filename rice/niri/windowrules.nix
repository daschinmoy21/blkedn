{
  config,
  lib,
  pkgs,
  ...
}: let
  globalBlurNeedle = "    draw-border-with-background false\n    geometry-corner-radius 9.000000 9.000000 9.000000 9.000000\n    clip-to-geometry true\n    opacity 0.930000";
  globalBlurReplacement = "    draw-border-with-background false\n    geometry-corner-radius 9.000000 9.000000 9.000000 9.000000\n    clip-to-geometry true\n    opacity 0.930000\n    background-effect { blur true; }";

  opaqueAppsNeedle = "    match app-id=\"^(Helium|helium|helium-browser|dev\\\\.zed\\\\.Zed|discord)$\"\n    opacity 1.000000";
  opaqueAppsReplacement = "    match app-id=\"^(Helium|helium|helium-browser|dev\\\\.zed\\\\.Zed|discord)$\"\n    opacity 1.000000\n    background-effect { blur false; }";

  # Gamescope / Proton / Lutris: do not composite through opacity+clip+blur.
  # That path breaks NVIDIA dma-buf presents (black or flashing, audio still plays).
  gameOpaqueNeedle = "    match app-id=\"^(gamescope|steam_app_.*)$\"\n    match app-id=\".*\\\\.[eE][xX][eE]$\"\n    open-fullscreen true\n    geometry-corner-radius 0.000000 0.000000 0.000000 0.000000\n    clip-to-geometry false\n    opacity 1.000000";
  gameOpaqueReplacement = "    match app-id=\"^(gamescope|steam_app_.*)$\"\n    match app-id=\".*\\\\.[eE][xX][eE]$\"\n    open-fullscreen true\n    geometry-corner-radius 0.000000 0.000000 0.000000 0.000000\n    clip-to-geometry false\n    opacity 1.000000\n    border { off; }\n    shadow { off; }\n    background-effect { blur false; }";

  renderedConfig = config.programs.niri.finalConfig;
  configWithBlur = builtins.replaceStrings
    [
      globalBlurNeedle
      opaqueAppsNeedle
      gameOpaqueNeedle
    ]
    [
      globalBlurReplacement
      opaqueAppsReplacement
      gameOpaqueReplacement
    ]
    ("blur {\n    passes 2\n    offset 0.5\n}\n" + renderedConfig);
in {
  programs.niri.settings = {
    window-rules = [
      # Work around WezTerm's initial configure bug
      {
        matches = [{ app-id = "^org\\.wezfurlong\\.wezterm$"; }];
        default-column-width = {};
      }

      # Global window styling
      {
        geometry-corner-radius = {
          top-left = 9.0;
          top-right = 9.0;
          bottom-left = 9.0;
          bottom-right = 9.0;
        };
        clip-to-geometry = true;
        opacity = 0.93;
        draw-border-with-background = false;
      }

      # Opacity rules for specific applications
      {
        matches = [{ app-id = "^(kitty|thunar|org\\.telegram\\.desktop|vesktop|org\\.gnome\\.Nautilus|nemo)$"; }];
        opacity = 0.9;
      }

      # Launch vesktop and Telegram on DP-3 monitor (Commented out for safety as monitor names differ)
      # {
      #   matches = [{ app-id = "^(vesktop|org\\.telegram\\.desktop)$"; }];
      #   open-on-output = "DP-3";
      # }

      # Zen Browser settings
      {
        matches = [{ app-id = "^zen-beta$"; }];
        opacity = 0.98;
        default-column-width = { proportion = 0.75; };
      }

      # No transparency for browsers/editors/chat that should stay fully opaque
      {
        matches = [{ app-id = "^(Helium|helium|helium-browser|dev\\.zed\\.Zed|discord)$"; }];
        opacity = 1.0;
      }

      # Games: compositor-fullscreen, no inset/border so mouse maps 1:1.
      # Keep the game itself in windowed/borderless; exclusive FS on xwayland
      # offsets the cursor by the decoration/hack a few pixels.
      {
        matches = [
          { app-id = "^(gamescope|steam_app_.*)$"; }
          { app-id = ".*\\.[eE][xX][eE]$"; }
        ];
        open-fullscreen = true;
        opacity = 1.0;
        clip-to-geometry = false;
        geometry-corner-radius = {
          top-left = 0.0;
          top-right = 0.0;
          bottom-left = 0.0;
          bottom-right = 0.0;
        };
      }

      # Zed settings
      {
        matches = [{ app-id = "^dev\\.zed\\.Zed$"; }];
        default-column-width = { proportion = 0.75; };
      }

      # Web apps and Steam opacity
      {
        matches = [{ app-id = "^(steam|chrome-app\\.restream\\.io__home-Default|chrome-claude\\.ai__new-Default|chrome-github\\.com__-Default|chrome-gitlab\\.com__theblackdon_black-don-os-Default|chrome-mail\\.proton\\.me__u_0_inbox-Default|chrome-meet\\.google\\.com__-Default|chrome-messages\\.google\\.com__web_u_1_conversations-Default|chrome-web\\.descript\\.com__-Default)$"; }];
        opacity = 0.95;
      }
    ];
  };

  xdg.configFile.niri-config.source = lib.mkForce (
    assert lib.hasInfix globalBlurNeedle renderedConfig;
    assert lib.hasInfix opaqueAppsNeedle renderedConfig;
    assert lib.hasInfix gameOpaqueNeedle renderedConfig;
    pkgs.runCommand "niri-config.kdl"
      {
        patchedConfig = configWithBlur;
        passAsFile = ["patchedConfig"];
        nativeBuildInputs = [config.programs.niri.package];
      }
      ''
        cp "$patchedConfigPath" "$out"
        niri validate -c "$out"
      ''
  );
}
