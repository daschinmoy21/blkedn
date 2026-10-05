{lib, ...}: {
  # GNOME Keyring auto-unlock on SDDM password login. Without this,
  # /etc/pam.d/sddm lacks pam_gnome_keyring.so, the login keyring stays
  # locked, and Electron apps (Claude, etc.) fall back to basic_text store
  # → "sign-in won't be saved" banner. sddm-autologin included for
  # completeness (note: autologin has no password, so it can't unlock —
  # use password login or a blank keyring password there).
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  security.pam.services.sddm-autologin.enableGnomeKeyring = true;
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
