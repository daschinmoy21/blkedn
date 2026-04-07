{
  lib,
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [
    ./noctalia.nix
    ./niri.nix
    ./nvf.nix
    ./evil-helix.nix
    #./matugen.nix
    # inputs.matugen.nixosModules.default
  ];

  gtk = {
    enable = true;
    font = {
      name = "Iosevka Aile";
      package = pkgs.iosevka;
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
      theme = config.gtk.theme;
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };


  gtk.gtk2.force = true;
  #xdg.configFile."gtk-3.0/gtk.css".source = "${config.programs.matugen.theme.files}/.config/gtk-3.0/gtk.css";

  #xdg.configFile."gtk-4.0/gtk.css".source = "${config.programs.matugen.theme.files}/.config/gtk-4.0/gtk.css";
}
