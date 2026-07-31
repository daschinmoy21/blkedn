{
  config,
  inputs,
  pkgs,
  ...
}:
# Start the following programs at launch
{
  programs.niri.settings.spawn-at-startup = [
    # noctalia is managed by its systemd user service — no manual spawn needed
    # wallpaper is managed by noctalia
  ];
}
