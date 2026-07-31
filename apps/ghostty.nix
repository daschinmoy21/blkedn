{pkgs, ...}: {
  home.packages = with pkgs; [
    ghostty
  ];

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      background = "#00070B";
      foreground = "#A9A9A9";
      cursor-color = "#9C9CA3";
      cursor-text = "#101010";
      palette = [
        "0=#333B3F"
        "1=#F26E74"
        "2=#78B892"
        "3=#E9967E"
        "4=#79AAEB"
        "5=#C488EC"
        "6=#78B892"
        "7=#A9A9A9"
        "8=#333B3F"
        "9=#E64A6B"
        "10=#789978"
        "11=#F0C674"
        "12=#78B892"
        "13=#B86CD4"
        "14=#78B892"
        "15=#F0F0F0"
      ];
      command = "${pkgs.fish}/bin/fish";
    };
  };
}
