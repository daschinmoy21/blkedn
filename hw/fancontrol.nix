{pkgs, ...}: {
  home.packages = with pkgs; [
    fanctl
  ];
}
