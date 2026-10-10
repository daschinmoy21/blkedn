{lib, ...}: {
  imports = [
    ./web.nix
    ./fish.nix
    ./editors.nix
    ./ghostty.nix
    ./tui.nix
    ./virt.nix
    ./hotspot.nix
    ./bitchord.nix
  ];

  programs = {
    feh = {
      enable = true; #image viewer
    };
  };
}
