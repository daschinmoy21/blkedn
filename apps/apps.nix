{lib, ...}: {
  imports = [
    ./web.nix
    ./fish.nix
    ./editors.nix
    ./ghostty.nix
    ./tui.nix
    ./virt.nix
    ./hotspot.nix
    ./eden.nix # official AppImage — no source build
  ];

  programs = {
    feh = {
      enable = true; #image viewer
    };
  };
}
