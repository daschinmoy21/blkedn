{
  pkgs,
  lib,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    vesktop
    vivaldi
    
    
  ];

  textfox = {
    enable = true;
    # Must match your profile name — check about:profiles if unsure
    profiles = ["4yxyoryv.default"];
    config = {
      displayNavButtons = true;
      displayWindowControls = true;

      # Force Dark Mode colors (Rosé Pine Moon inspired)
      background.color = "#232136";
      border.color = "#393552";
      font.family = "\"Iosevka\"";
      font.accent = "#eb6f92";

      # Force Sidebery & built-in pages to match our theme explicitly
      extraConfig = ''
        /* Override Sidebery colors that don't inherit correctly */
        @-moz-document url-prefix("moz-extension://") {
          :root {
            --frame-bg: #232136 !important;
            --toolbar-bg: #232136 !important;
            --main-bg: #232136 !important;
            --main-fg: #e0def4 !important;
          }
        }
      '';
    };
  };

  programs.firefox.profiles."4yxyoryv.default".settings = {
    "ui.systemUsesDarkTheme" = 1;
    "browser.theme.content-theme" = 0;
    "browser.theme.toolbar-theme" = 0;
    "browser.in-content.dark-mode" = true;
    "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
  };
}
