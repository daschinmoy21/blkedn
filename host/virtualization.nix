{
  pkgs,
  config,
  lib,
  ...
}: {
  # Enable Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    # Convert to podman if needed, but per plan using docker
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };

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

  programs.virt-manager.enable = true;

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
