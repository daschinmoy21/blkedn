{lib, ...}: {
  imports = [
    ./web.nix
    ./fish.nix
    ./editors.nix
    ./ghostty.nix
    ./tui.nix
    ./virt.nix
  ];

  programs = {
    feh = {
      enable = true; #image viewer
    };
  };
}
