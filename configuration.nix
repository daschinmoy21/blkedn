# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./host/host-configuration.nix
    ./hw/nvidia.nix
    ./hw/sleep.nix
    ./host/virtualization.nix
  ];

  wrappers.pi.enable = true;

  # NOTE: do NOT override openldap here. It sits under easyeffects via
  # lsp-plugins -> php -> php-ldap, so any overrideAttrs on it changes the
  # drv hash and forces easyeffects + friends to rebuild from source.
  # With no overlay, openldap/easyeffects come straight from cache.nixos.org
  # as binaries (tests only run on source builds, so a flaky upstream test
  # can't fail a cached download).
  nixpkgs.overlays = [
    (final: prev: {
      # ponytail: pandas<3.0.0 constraint in sherlock's pyproject.toml; nixpkgs ships pandas 3.0.4
      # remove when sherlock upstream supports pandas 3.x
      # Leaf-only override (sherlock alone rebuilds, nothing else).
      sherlock = prev.sherlock.overridePythonAttrs (old: {
        pythonRelaxDeps = ["pandas"];
      });
      grok-bot = final.callPackage ./pkgs/grok-bot.nix {};
      # Prebuilt upstream nightly AppImage (see pkgs/t3code-nightly.nix).
      # Replaces nixpkgs stable `t3code`; no source builds involved.
      t3code-nightly = final.callPackage ./pkgs/t3code-nightly.nix {};
    })
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages;

  # kernel modules for system fan control
  boot.kernelModules = ["nct6775"];

  # Allow different filesystems
  boot.supportedFilesystems = ["ntfs" "exfat" "ext4"];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # allow Insecure Packages
  # electron-40: winboat; electron-36: leftover Electron apps still on that pin
  nixpkgs.config.permittedInsecurePackages = [
    "electron-36.9.5"
    "electron-40.10.5"
  ];

  # enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Enable Home Manager
  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = {inherit inputs;};
    users = {
      "crimxnhaze" = import ./home.nix;
    };
    # Allow backups when files conflict
    backupFileExtension = "hm-backup";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  users.users.crimxnhaze.shell = pkgs.fish;

  # Enable the OpenSSH daemon (for Hadoop localhost SSH).
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
