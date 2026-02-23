{...}: {
  programs.niri.settings = {
    window-rules = [
      # Work around WezTerm's initial configure bug
      {
        matches = [{ app-id = "^org\\.wezfurlong\\.wezterm$"; }];
        default-column-width = {};
      }

      # Open the Firefox picture-in-picture player as floating by default
      {
        matches = [{ app-id = "firefox$"; title = "^Picture-in-Picture$"; }];
        open-floating = true;
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
        matches = [{ app-id = "^(kitty|thunar|org\\.telegram\\.desktop|discord|vesktop|org\\.gnome\\.Nautilus|nemo)$"; }];
        opacity = 0.9;
      }

      # Launch vesktop and Telegram on DP-3 monitor (Commented out for safety as monitor names differ)
      # {
      #   matches = [{ app-id = "^(vesktop|org\\.telegram\\.desktop)$"; }];
      #   open-on-output = "DP-3";
      # }

      # Zen Browser and Zed settings
      {
        matches = [{ app-id = "^(zen-beta|dev\\.zed\\.Zed)$"; }];
        opacity = 0.98;
        default-column-width = { proportion = 0.75; };
      }

      # Web apps and Steam opacity
      {
        matches = [{ app-id = "^(steam|chrome-app\\.restream\\.io__home-Default|chrome-claude\\.ai__new-Default|chrome-github\\.com__-Default|chrome-gitlab\\.com__theblackdon_black-don-os-Default|chrome-mail\\.proton\\.me__u_0_inbox-Default|chrome-meet\\.google\\.com__-Default|chrome-messages\\.google\\.com__web_u_1_conversations-Default|chrome-web\\.descript\\.com__-Default)$"; }];
        opacity = 0.95;
      }
    ];
  };
}
