{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  programs.noctalia = {
    enable = true;
    # nixpkgs build (cache.nixos.org): shares glibc with the system GL drivers.
    # The flake package pins older nixpkgs (glibc 2.42 vs 2.44) and dies with
    # "eglGetDisplay failed" when it dlopens the drivers.
    package = pkgs.noctalia;
    systemd.enable = true;
    recommendedServices.enable = true;
  };
}
