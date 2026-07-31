{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
in {
  programs.noctalia = {
    enable = true;
    package = inputs.noctalia.packages.${system}.default;
    systemd.enable = true;
    recommendedServices.enable = true;
  };
}
