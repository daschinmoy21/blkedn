{
  inputs,
  pkgs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
in {
  home.packages = [
    pkgs.rofi
    pkgs.playerctl
    inputs.quickshell.packages.${system}.quickshell
  ];

  xdg.configFile = {
    "quickshell".source = ./amadeus/quickshell;
    "rofi".source = ./amadeus/rofi;
  };
}
