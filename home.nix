{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  home.username = "crimxnhaze";
  home.homeDirectory = "/home/crimxnhaze";

  imports = [
    ./rice/rice.nix
    ./apps/apps.nix
    ./hw/hw.nix
  ];

  home.stateVersion = "26.05";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    inputs.antigravity-nix.packages.${pkgs.system}.default
    inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-ide
    inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-cli
  ];

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  programs.home-manager.enable = true;
}
