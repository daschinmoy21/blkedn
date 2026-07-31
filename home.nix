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
    inputs.codex-desktop-linux.homeManagerModules.default
  ];

  home.stateVersion = "25.05";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    eog
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-ide
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli

    inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default

    # migrated from nix profile
    fastfetch
    file-roller
    github-copilot-cli
    witr
    ytmdesktop

    # external flake packages
    inputs.ccusage-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.omp-nix.packages.${pkgs.stdenv.hostPlatform.system}.oh-my-pi
  ];

  programs.codexDesktopLinux = {
    enable = true;
    cliPackage = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
    remoteControl.enable = true;
  };

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  programs.home-manager.enable = true;
}
