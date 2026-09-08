{lib, ...}: {
  # Boot login: SDDM + qylock theme (matches session lock via qylock-lock).
  # Lock screen: Quickshell qylock-lock (Mod+Alt+L) — see host/qylock.nix.
  # Theme install + active SDDM theme: programs.qylock in host/qylock.nix
  # https://github.com/Darkkal44/qylock

  services.greetd.enable = lib.mkForce false;

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      # Optional: stop virtual keyboard auto-popup (qylock FAQ)
      settings = {
        General = {
          InputMethod = "";
        };
      };
    };
    # Session .desktop files from programs.niri (host/programs.nix)
    defaultSession = "niri";
  };
}
