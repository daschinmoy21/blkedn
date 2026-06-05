{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  # Mount Points for SSDs
  fileSystems."/home/crimxnhaze/SSD2" = {
    device = "/dev/disk/by-uuid/0F27AA6C443BF732";
    fsType = "ntfs";
    options = ["nofail" "x-systemd.device-timeout=1s" "x-systemd.automount" "uid=1000" "gid=100"];
  };

  fileSystems."/home/crimxnhaze/SSD3" = {
    device = "/dev/disk/by-uuid/5AECAF24ECAEF981";
    fsType = "ntfs";
    options = ["nofail" "x-systemd.device-timeout=1s" "x-systemd.automount" "uid=1000" "gid=100"];
  };

  systemd.tmpfiles.rules = [
    "d /home/crimxnhaze/SSD2 0755 crimxnhaze users"
    "d /home/crimxnhaze/SSD3 0755 crimxnhaze users"
  ];

  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 20 * 1024;
  } ];
}
