{
  pkgs,
  lib,
  ...
}: let
  hotspot = pkgs.writeShellApplication {
    name = "hotspot";
    runtimeInputs = with pkgs; [
      networkmanager # nmcli
      iproute2
      iw
      fzf
      qrencode
      gawk
      gnused
      gnugrep
      coreutils
    ];
    text = builtins.readFile ../tools/hotspot/hotspot;
  };
in {
  home.packages = [hotspot];
}
