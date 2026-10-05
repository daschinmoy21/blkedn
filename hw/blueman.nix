{pkgs, ...}: {
  home.packages = with pkgs; [
    bluez-tools
  ];
}
