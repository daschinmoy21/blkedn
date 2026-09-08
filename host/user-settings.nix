{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  # Define a user account. set a password with ‘passwd’.
  users.users.crimxnhaze = {
    isNormalUser = true;
    description = "crimxnhaze";
    # "docker" is needed to talk to the system Docker daemon without sudo.
    # Warning: docker group membership is effectively root-equivalent.
    # "kvm" is required for Docker Sandboxes (sbx) microVMs.
    extraGroups = ["networkmanager" "wheel" "kvm" "libvirtd" "samba" "vboxusers" "docker"];
    packages = with pkgs; [
      #  kdePackages.kate #useful to have on hand tbh!
      #  thunderbird
    ];
  };

  environment = {
    variables = {
      SHELL = "fish";
      EDITOR = "zededitor";
      VISUAL = "zededitor";
      # DOCKER_HOST left unset → host Docker Engine (unix:///var/run/docker.sock).
      # Podman rootless socket (for tools that need it explicitly):
      #   unix:///run/user/1000/podman/podman.sock
      # Projects that invoke `podman` directly do not need DOCKER_HOST.
    };
  };

  # Define hostname.
  networking.hostName = "nixos";
  networking.firewall.extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocales = [
    "ja_JP.UTF-8/UTF-8"
  ];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
}
