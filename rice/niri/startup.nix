{
  config,
  inputs,
  pkgs,
  ...
}:
# Start the following programs at launch
{
  programs.niri.settings.spawn-at-startup = [
    {command = ["quickshell" "-p" "/home/crimxnhaze/.config/quickshell"];}
    {command = ["awww-daemon"];}
    {command = ["awww" "img" "/home/crimxnhaze/walls/katana.png"];}
  ];
}
