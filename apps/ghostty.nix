{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    ghostty
  ];

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      theme = "Batman";
      command = "${pkgs.fish}/bin/fish";
      "font-family" = "Iosevka";
    };
  };

  # Avoid Home Manager activation failures when an older backup already exists.
  xdg.configFile."ghostty/config".force = true;
}
