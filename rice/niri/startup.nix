{
  config,
  inputs,
  pkgs,
  ...
}:
# Start the following programs at launch
{
  programs.niri.settings.spawn-at-startup = [
    # {command = ["dms" "run"];}
    {command = ["awww-daemon"];}
    {command = ["awww" "img" "/home/crimxnhaze/walls/katana.png"];}
  ];
}
