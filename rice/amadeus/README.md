# Amadeus rice (Niri)

Horizontal **top bar** port of [Amadeus](https://github.com/daschinmoy21/amadeus) for Niri + Quickshell.

## Layout

- Top exclusive zone bar (`shell.qml`)
- Left: profile, volume, weather, CPU/RAM
- Center: Niri workspaces (clickable pills)
- Right: tray, media, battery/net, power, clock

## Clicks

| Control | Action |
| --- | --- |
| Profile | L: rofi · R: niri overview |
| Volume | click mute · wheel volume |
| Weather | click refresh |
| Workspaces | click focus |
| Tray | L activate · R menu |
| Media | L prev · R next · M play/pause |
| Battery/net | click refresh / network editor |
| Power | Click opens dialog; Lock immediate; Logout/Reboot/Shutdown need second confirm |

## Notes

- No DMS; uses flake `quickshell` + `pkgs.rofi` + `playerctl`
- No Hyprland / Cartograph fonts
- Restart after switch: `quickshell -p ~/.config/quickshell -n -d`
- `nh os test` does **not** survive reboot — use `nh os switch` / `build`
