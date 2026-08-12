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
    inputs.herdr-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs.codexDesktopLinux = {
    enable = true;
    cliPackage = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
    remoteControl.enable = true;
  };

  home.file.".local/bin/command-code-desktop" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      exec "$HOME/.local/opt/command-code/opt/Command Code/command-code" "$@"
    '';
  };

  xdg.desktopEntries.command-code = {
    name = "Command Code";
    exec = "command-code-desktop %U";
    icon = "${config.home.homeDirectory}/.local/opt/command-code/usr/share/icons/hicolor/256x256/apps/command-code.png";
    comment = "Command Code desktop app";
    categories = ["Development"];
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
  ];

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  programs.home-manager.enable = true;
}
