{pkgs, ...}: {
  home.packages = with pkgs; [
    ghostty
  ];

  # Config is left unmanaged (~/.config/ghostty/config) so Noctalia can write its theme into it
}
