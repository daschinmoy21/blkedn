{
  pkgs,
  config,
  lib,
  ...
}: {
  # Enable Docker
  virtualisation.docker = {
    enable = true;
    # Convert to podman if needed
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
      runAsRoot = true;
      swtpm.enable = true;
    };
    allowedBridges = ["virbr0"];
  };

  # Bypass libvirt's secret-state encryption entirely. It is not required for
  # running QEMU/KVM or Windows guests, and the encrypted credential path is
  # currently preventing libvirtd from starting on this host.
  systemd.packages = [
    (pkgs.runCommand "libvirtd-secret-bypass" {} ''
      mkdir -p $out/lib/systemd/system/libvirtd.service.d
      cat > $out/lib/systemd/system/libvirtd.service.d/override.conf <<'EOF'
      [Unit]
      Requires=
      After=

      [Service]
      LoadCredentialEncrypted=
      Environment=SECRETS_ENCRYPTION_KEY=
      EOF
    '')
  ];

  # Ensure default network exists and starts
  networking.firewall.trustedInterfaces = ["virbr0"];

  programs.virt-manager.enable = true;
  security.polkit.enable = true;

  # Kernel modules for KVM and VFIO
  boot.kernelModules = ["kvm-intel" "vfio-pci"];

  specialisation."virtualbox".configuration = {
    system.nixos.tags = ["virtualbox-mode"];
    boot.blacklistedKernelModules = ["kvm-intel" "kvm"];
    virtualisation.libvirtd.enable = lib.mkForce false;
    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };

  # Kernel params for Intel IOMMU
  boot.kernelParams = ["intel_iommu=on" "iommu=pt"];

  specialisation."vfio".configuration = {
    system.nixos.tags = ["with-vfio"];
    # Keep base IOMMU flags and append VFIO IDs in this specialization.
    boot.kernelParams = lib.mkAfter ["vfio-pci.ids=10de:28e1,10de:22be"];
    boot.blacklistedKernelModules = ["nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" "nouveau"];
    virtualisation.libvirtd.qemu.swtpm.enable = lib.mkForce false;
  };

  # Enable OpenGL/Graphics for VMs
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # OpenGL is already enabled above



  # Looking Glass setup
  environment.systemPackages = with pkgs; [
    looking-glass-client
  ];

  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 crimxnhaze qemu-libvirtd -"
  ];

}
