{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  # Helper to make spawn actions cleaner
  spawn = cmd:
    if builtins.isList cmd
    then cmd
    else [cmd];
in {
  programs.niri.settings.binds = with config.lib.niri.actions; {
    # === System & Overview ===
    "Mod+X".action = toggle-overview;
    "Mod+O".action = toggle-overview;
    "Mod+Shift+Slash".action = show-hotkey-overlay;

    # === Application Launchers ===
    "Mod+T".action.spawn = spawn "${pkgs.ghostty}/bin/ghostty"; # Changed to match existing terminal choice often used, or use config.terminal if available, but staying safe with what was there
    "Mod+Return".action.spawn = spawn "${pkgs.ghostty}/bin/ghostty";
    "Mod+Space".action.spawn = spawn ["${pkgs.rofi}/bin/rofi" "-show" "drun"];
    "Mod+Comma".action.spawn = spawn ["${pkgs.rofi}/bin/rofi" "-show" "drun"];
    "Mod+Alt+S".action.spawn = spawn ["${pkgs.rofi}/bin/rofi" "-show" "drun"];
    "Mod+Shift+C".action.spawn = spawn ["${pkgs.rofi}/bin/rofi" "-show" "drun"];

    # === Audio Controls (Wpctl) ===
    "XF86AudioRaiseVolume".action.spawn = spawn ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"];
    "XF86AudioLowerVolume".action.spawn = spawn ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"];
    "XF86AudioMute".action.spawn = spawn ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
    "XF86AudioMicMute".action.spawn = spawn ["wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];
    "XF86AudioRaiseVolume".allow-when-locked = true;
    "XF86AudioLowerVolume".allow-when-locked = true;
    "XF86AudioMute".allow-when-locked = true;
    "XF86AudioMicMute".allow-when-locked = true;

    # === Security ===
    "Mod+Shift+Q".action = quit;

    # === Keyboard Brightness ===
    "XF86KbdBrightnessUp".action.spawn = spawn ["kbdbrite.sh" "up"];
    "XF86KbdBrightnessDown".action.spawn = spawn ["kbdbrite.sh" "down"];
    "XF86KbdBrightnessUp".allow-when-locked = true;
    "XF86KbdBrightnessDown".allow-when-locked = true;

    # === Window Management ===
    "Mod+Q".action = close-window;
    "Mod+Alt+F".action = maximize-column;
    "Mod+Shift+F".action = fullscreen-window;
    "Mod+W".action = toggle-window-floating;
    "Mod+Ctrl+W".action = switch-focus-between-floating-and-tiling;
    "Mod+V".action = toggle-column-tabbed-display;

    # === Focus Navigation ===
    "Mod+Left".action = focus-column-left;
    "Mod+Down".action = focus-window-down;
    "Mod+Up".action = focus-window-up;
    "Mod+Right".action = focus-column-right;
    "Mod+H".action = focus-column-left;
    "Mod+J".action = focus-window-down;
    "Mod+K".action = focus-window-up;
    "Mod+L".action = focus-column-right;

    # === Window Movement ===
    "Mod+Shift+Left".action = move-column-left;
    "Mod+Shift+Down".action = move-window-down;
    "Mod+Shift+Up".action = move-window-up;
    "Mod+Shift+Right".action = move-column-right;
    "Mod+Shift+H".action = move-column-left;
    "Mod+Shift+J".action = move-window-down;
    "Mod+Shift+K".action = move-window-up;
    "Mod+Shift+L".action = move-column-right;

    # === Column Navigation ===
    "Mod+Home".action = focus-column-first;
    "Mod+End".action = focus-column-last;
    "Mod+Ctrl+Home".action = move-column-to-first;
    "Mod+Ctrl+End".action = move-column-to-last;

    # === Monitor Navigation ===
    "Mod+Ctrl+Left".action = focus-monitor-left;
    "Mod+Ctrl+Right".action = focus-monitor-right;
    "Mod+Ctrl+H".action = focus-monitor-left;
    "Mod+Ctrl+J".action = focus-monitor-down;
    "Mod+Ctrl+K".action = focus-monitor-up;
    "Mod+Ctrl+L".action = focus-monitor-right;

    # === Move to Monitor ===
    "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
    "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
    "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
    "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
    "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
    "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
    "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
    "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;

    # === Workspace Navigation ===
    "Mod+U".action = focus-workspace-down;
    "Mod+I".action = focus-workspace-up;
    "Mod+Ctrl+Down".action = focus-workspace-down;
    "Mod+Ctrl+Up".action = focus-workspace-up;
    "Mod+Ctrl+Alt+Down".action = move-column-to-workspace-down;
    "Mod+Ctrl+Alt+Up".action = move-column-to-workspace-up;
    "Mod+Shift+Page_Down".action = move-workspace-down;
    "Mod+Shift+Page_Up".action = move-workspace-up;
    "Mod+Shift+U".action = move-workspace-down;
    "Mod+Shift+I".action = move-workspace-up;

    # === Mouse Wheel Navigation ===
    "Mod+WheelScrollDown".action = focus-workspace-down;
    "Mod+WheelScrollDown".cooldown-ms = 150;
    "Mod+WheelScrollUp".action = focus-workspace-up;
    "Mod+WheelScrollUp".cooldown-ms = 150;
    "Mod+Ctrl+WheelScrollDown".action = move-column-to-workspace-down;
    "Mod+Ctrl+WheelScrollDown".cooldown-ms = 150;
    "Mod+Ctrl+WheelScrollUp".action = move-column-to-workspace-up;
    "Mod+Ctrl+WheelScrollUp".cooldown-ms = 150;

    "Mod+WheelScrollRight".action = focus-column-right;
    "Mod+WheelScrollLeft".action = focus-column-left;
    "Mod+Ctrl+WheelScrollRight".action = move-column-right;
    "Mod+Ctrl+WheelScrollLeft".action = move-column-left;

    "Mod+Shift+WheelScrollDown".action = focus-column-right;
    "Mod+Shift+WheelScrollUp".action = focus-column-left;
    "Mod+Ctrl+Shift+WheelScrollDown".action = move-column-right;
    "Mod+Ctrl+Shift+WheelScrollUp".action = move-column-left;

    # === Numbered Workspaces ===
    "Mod+1".action = {focus-workspace = 1;};
    "Mod+2".action = {focus-workspace = 2;};
    "Mod+3".action = {focus-workspace = 3;};
    "Mod+4".action = {focus-workspace = 4;};
    "Mod+5".action = {focus-workspace = 5;};
    "Mod+6".action = {focus-workspace = 6;};
    "Mod+7".action = {focus-workspace = 7;};
    "Mod+8".action = {focus-workspace = 8;};
    "Mod+9".action = {focus-workspace = 9;};

    "Mod+Ctrl+1".action = {move-column-to-workspace = 1;};
    "Mod+Ctrl+2".action = {move-column-to-workspace = 2;};
    "Mod+Ctrl+3".action = {move-column-to-workspace = 3;};
    "Mod+Ctrl+4".action = {move-column-to-workspace = 4;};
    "Mod+Ctrl+5".action = {move-column-to-workspace = 5;};
    "Mod+Ctrl+6".action = {move-column-to-workspace = 6;};
    "Mod+Ctrl+7".action = {move-column-to-workspace = 7;};
    "Mod+Ctrl+8".action = {move-column-to-workspace = 8;};
    "Mod+Ctrl+9".action = {move-column-to-workspace = 9;};

    # === Column Management ===
    "Mod+BracketLeft".action = consume-or-expel-window-left;
    "Mod+BracketRight".action = consume-or-expel-window-right;
    "Mod+Period".action = expel-window-from-column;

    # === Sizing & Layout ===
    "Mod+R".action = switch-preset-column-width;
    "Mod+Shift+R".action = switch-preset-window-height;
    "Mod+Ctrl+R".action = reset-window-height;
    "Mod+Ctrl+F".action = expand-column-to-available-width;
    "Mod+Ctrl+C".action = center-column;

    # === Manual Sizing ===
    "Mod+Minus".action = set-column-width "-10%";
    "Mod+Equal".action = set-column-width "+10%";
    "Mod+Shift+Minus".action = set-window-height "-10%";
    "Mod+Shift+Equal".action = set-window-height "+10%";

    # === Screenshots ===
    "Mod+Shift+S".action.screenshot = {};
    "XF86Launch1".action.screenshot = {};
    "Ctrl+XF86Launch1".action.screenshot-screen = {};
    "Alt+XF86Launch1".action.screenshot-window = {};
    "Print".action.screenshot = {};
    "Ctrl+Print".action.screenshot-screen = {};
    "Alt+Print".action.screenshot-window = {};

    # === Custom Application Launchers ===
    "Mod+G".action.spawn = spawn "telegram-desktop";
    # "Mod+Shift+Ctrl+C".action.spawn = spawn ["ghostty" "claude"];
    "Ctrl+Mod+N".action.spawn = spawn "obsidian";
    "Mod+B".action.spawn = spawn "zen";
    "Mod+D".action.spawn = spawn "vesktop";
    "Mod+S".action.spawn = spawn "steam";
    "Mod+Shift+O".action.spawn = spawn "obs";
    "Mod+F".action.spawn = spawn "thunar";
    "Ctrl+Mod+V".action.spawn = spawn "virt-manager";

    # === Color picker ===
    # "Mod+C".action.spawn = [ "sh" "-c" "niri msg pick-color | grep 'Hex:' | cut -d' ' -f2 | wl-copy" ];

    # === Dynamic Cast ===
    # "Mod+P".action = set-dynamic-cast-monitor; # These might need niri version check or implementation check
    # "Mod+Shift+P".action = set-dynamic-cast-window;
    # "Mod+Ctrl+P".action = clear-dynamic-cast-target;
  };
}
