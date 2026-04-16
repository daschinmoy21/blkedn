{pkgs, ...}: {
  home.packages = with pkgs; [
    ghostty
  ];

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      theme = "Matte Black";
      command = "${pkgs.fish}/bin/fish";
    };
  };
}
