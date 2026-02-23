# NVIDIA Laptop Driver Configuration
# Based on black-don-os nvidia-prime-drivers.nix and nvidia-drivers.nix
{
  config,
  pkgs,
  lib,
  ...
}: {
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Load NVIDIA driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is required for Wayland
    modesetting.enable = true;

    # Nvidia power management. Experimental, can cause sleep/suspend to fail.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not nouveau).
    # Support is limited to the Turing and later architectures.
    # Only available from driver 515.43.04+
    open = true;

    # Enable the Nvidia settings menu, accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Use the latest driver version
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # PRIME configuration for hybrid graphics (Intel + NVIDIA laptop)
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # Bus IDs - find with: lspci | grep -E "VGA|3D"
      # Format: "PCI:bus:device:function"
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
