{
  lib,
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [
    ./niri.nix
    ./amadeus.nix
    ./nvf.nix
    ./evil-helix.nix
  ];

  gtk = {
    enable = true;
    font = {
      name = "Iosevka Nerd Font";
      package = pkgs.nerd-fonts.iosevka;
      size = 12;
    };

    iconTheme = {
      name = "Dracula";
      package = pkgs.dracula-icon-theme;
    };

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    gtk3 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    gtk4 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };

  gtk.gtk2.force = true;
  gtk.gtk4.theme = config.gtk.theme;
}
