{pkgs, ...}: {
  home.packages = with pkgs; [
    spice-gtk
    virtio-win
  ];

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
