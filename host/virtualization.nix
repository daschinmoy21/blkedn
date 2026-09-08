{
  pkgs,
  config,
  lib,
  ...
}: {
  # Docker + Podman side by side.
  #   - Docker Engine / sbx for Docker workflows & agent sandboxes
  #   - Podman for projects that shell out to `podman` (rootless)
  #
  # Do NOT enable podman.dockerCompat — that installs a `docker` shim and
  # collides with real Docker Engine. Call `podman` / `docker` explicitly.
  # Membership in the "docker" group is effectively root-equivalent.
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = ["--all"];
    };
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = false;
    # Conflicts with virtualisation.docker.enable (only one can own the system
    # docker.sock). Rootless Podman still exposes:
    #   unix:///run/user/$UID/podman/podman.sock
    dockerSocket.enable = false;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Prefer Docker for declarative NixOS oci-containers
  virtualisation.oci-containers.backend = "docker";

  # Enable Libvirt/KVM (required for sbx microVMs on Linux)
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      runAsRoot = false;
      swtpm.enable = true;
    };
    allowedBridges = ["virbr0"];
  };

  systemd.services.libvirtd.wantedBy = lib.mkForce [];

  # Ensure default network exists and starts
  networking.firewall.trustedInterfaces = ["virbr0"];

  networking.extraHosts = ''
    127.0.0.1 kubernetes.docker.internal
  '';

  programs.dconf.enable = true;
  programs.virt-manager.enable = true;

  services.spice-vdagentd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  environment.systemPackages = with pkgs; [
    docker-compose
    docker-buildx
    docker-sbx # sbx CLI — Docker Sandboxes microVMs for AI agents

    # Podman tooling (CLI comes from virtualisation.podman)
    podman-compose
    podman-desktop

    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
  ];

  # Kernel modules for KVM and VFIO
  boot.kernelModules = ["kvm-intel" "vfio-pci"];

  # Kernel params for Intel IOMMU
  boot.kernelParams = ["intel_iommu=on" "iommu=pt"];

  # Enable OpenGL/Graphics for VMs
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
