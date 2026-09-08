# NVIDIA laptop driver — hybrid mux (BIOS Auto).
# Intel drives the panel; niri composites on the iGPU.
# Games / CUDA: prefix with nvidia-offload (from enableOffloadCmd).
# For dGPU-only BIOS mux: comment out prime, set finegrained = false,
# and add boot.kernelParams = ["nvidia-drm.fbdev=1"].
{
  config,
  pkgs,
  lib,
  ...
}: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;

    # Save/restore VRAM across S3. Without this, every resume logs Xid 13
    # on niri/helium/electron and nvidia-drm atomic modeset fails with -11.
    # Fine-grained runtime PM needs PRIME + a live iGPU (this mux).
    powerManagement.enable = true;
    powerManagement.finegrained = true;

    # Ada (RTX 4050) — open kernel module.
    open = true;

    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
