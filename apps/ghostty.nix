{pkgs, ...}: {
  home.packages = with pkgs; [
    ghostty
  ];

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      # Matches nvim base16-ayu-dark (bg #0b0e14)
      theme = "Ayu";
      command = "${pkgs.fish}/bin/fish";

    };
  };
}
