{
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [
    # import settings broken out into other files
    ./niri/startup.nix
    ./niri/keybinds.nix
    ./niri/layout.nix
    ./niri/windowrules.nix
    ./niri/layerrules.nix
    ./niri/overview.nix
    ./niri/portals.nix
  ];

  programs.niri = {
    settings = {
      prefer-no-csd = true;
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
      hotkey-overlay.skip-at-startup = true;
      environment = {
        NIXOS_OZONE_WL = "1";
      };
      cursor = {
        hide-after-inactive-ms = 60000;
        hide-when-typing = true;
        theme = "catppuccin-frappe-dark-cursors";
        size = 22;
      };
      input = {
        mouse = {
          accel-speed = 0.0;
          accel-profile = "flat";
        };
      };
      # Panel advertises 60.025 as preferred; without this niri stays at 60 Hz.
      outputs."eDP-1" = {
        mode = {
          width = 1920;
          height = 1200;
          refresh = 165.002;
        };
      };
    };
  };
}
