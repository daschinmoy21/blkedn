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
    ./noctalia.nix
    ./qylock.nix
    ./greeter.nix
    ./services.nix
    ./yt-cookies.nix
    ./user-settings.nix
    # ./priv/priv.nix
  ];
}
