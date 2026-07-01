{
  pkgs,
  config,
  lib,
  ...
}: {
  # Podman (rootless, Docker-compatible)
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  virtualisation.docker.enable = false;

  # Enable Libvirt/KVM
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

  programs.dconf.enable = true;
  programs.virt-manager.enable = true;

  services.spice-vdagentd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  environment.systemPackages = with pkgs; [
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
  # Kernel params for Intel IOMMU
  boot.kernelParams = ["intel_iommu=on" "iommu=pt"];

  # Enable OpenGL/Graphics for VMs
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
