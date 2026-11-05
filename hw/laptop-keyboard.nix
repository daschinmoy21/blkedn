# Lets the user disable the built-in keyboard while an external one sits on top of it.
# The Noctalia bar button lives in its own repo and calls `laptop-kbd`.
#
# The rule only opens this one sysfs file to wheel. Joining the `input` group would
# work too, but it would let every user process read all keystrokes.
# The file resets on reboot, so the keyboard always comes back on.
{pkgs, ...}: {
  environment.systemPackages = [pkgs.laptop-kbd];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", KERNEL=="input[0-9]*", ATTR{name}=="AT Translated Set 2 keyboard", ATTR{phys}=="isa0060/serio0/input0", RUN+="${pkgs.coreutils}/bin/chgrp wheel /sys%p/inhibited", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys%p/inhibited"
  '';
}
