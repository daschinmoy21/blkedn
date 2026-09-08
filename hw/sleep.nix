# Acer Predator PHN16-71 (Raptor Lake + RTX 4050, Killer AX1650i).
# S3 resume currently logs three independent failures. This file covers
# the SPD I2C one and the iwlwifi one. NVIDIA VRAM save/restore lives
# in nvidia.nix.
{
  pkgs,
  ...
}: {
  # DDR5 temperature sensors on i2c-i801. Every S3 resume:
  #   spd5118 0-0050: Failed to write b = 0: -6
  #   spd5118_resume returns -6 (ENXIO)
  # BIOS already set SPD Write Disable, so the write cannot succeed.
  # Losing DIMM temps in CoolerControl is the cost.
  boot.blacklistedKernelModules = ["spd5118"];

  # Killer AX1650i (iwlwifi so-a0-hr-b0). After resume: RFIm reason 5,
  # beacon loss, then NM roams campus APs until association times out.
  # Keep the radio out of firmware power-save.
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0
    options iwlmvm power_scheme=1
  '';

  networking.networkmanager.wifi.powersave = false;
  # Campus 802.1X + Killer firmware after S3 mishandles randomized scan MACs.
  networking.networkmanager.wifi.scanRandMacAddress = false;

  # Firmware is half-alive after S3 (associates, then drops). Reload it.
  powerManagement.resumeCommands = ''
    ${pkgs.kmod}/bin/modprobe -r iwlmvm iwlwifi || true
    ${pkgs.coreutils}/bin/sleep 1
    ${pkgs.kmod}/bin/modprobe iwlwifi || true
  '';
}
