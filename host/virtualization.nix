{
  pkgs,
  config,
  lib,
  ...
}: {
  # Enable Docker
  virtualisation.docker = {
    enable = true;
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

  # Ensure default network exists and starts
  networking.firewall.trustedInterfaces = ["virbr0"];

  programs.virt-manager.enable = true;

  # Kernel modules for KVM and VFIO
  boot.kernelModules = ["kvm-intel" "vfio-pci"];

  specialisation."virtualbox".configuration = {
    system.nixos.tags = ["virtualbox-mode"];
    boot.blacklistedKernelModules = ["kvm-intel" "kvm"];
    virtualisation.libvirtd.enable = lib.mkForce false;
  };

  # Kernel params for Intel IOMMU
  # Kernel params for Intel IOMMU
  boot.kernelParams = ["intel_iommu=on" "iommu=pt"];

  specialisation."vfio".configuration = {
    system.nixos.tags = ["with-vfio"];
    boot.kernelParams = ["vfio-pci.ids=10de:28e1,10de:22be"];
  };

  # Enable OpenGL/Graphics for VMs
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable VirtualBox
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };
}
