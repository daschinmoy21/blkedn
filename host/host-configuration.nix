{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./drives.nix
    ./programs.nix
    ./greeter.nix
    ./services.nix
    ./user-settings.nix
    ./udev.nix
    # ./priv/priv.nix
  ];
}
