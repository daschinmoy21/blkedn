{
  pkgs,
  lib,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.system}.default
  ];
}
