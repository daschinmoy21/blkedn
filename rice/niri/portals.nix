{
  pkgs,
  config,
  lib,
  ...
}: {
  # Install necessary portal packages
  home.packages = with pkgs; [
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
  ];

  # XDG Desktop Portal services - properly configured for screen sharing
  systemd.user.services.xdg-desktop-portal = {
    Service = {
      ExecStart = "${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal";
      Environment = [
        "XDG_CURRENT_DESKTOP=niri"
        "WAYLAND_DISPLAY=wayland-1"
      ];
    };
  };

  systemd.user.services.xdg-desktop-portal-gnome = {
    Service = {
      ExecStart = "${pkgs.xdg-desktop-portal-gnome}/libexec/xdg-desktop-portal-gnome";
      Environment = [
        "XDG_CURRENT_DESKTOP=niri"
      ];
    };
  };

  # XDG Desktop Portal configuration for Niri
  xdg.configFile."xdg-desktop-portal/portals.conf".text = ''
    [preferred]
    default=gtk
    org.freedesktop.impl.portal.FileChooser=gtk
    org.freedesktop.impl.portal.Screenshot=gnome
    org.freedesktop.impl.portal.ScreenCast=gnome
  '';

  xdg.configFile."xdg-desktop-portal/niri-portals.conf".text = ''
    [preferred]
    default=gtk
    org.freedesktop.impl.portal.FileChooser=gtk
    org.freedesktop.impl.portal.Screenshot=gnome
    org.freedesktop.impl.portal.ScreenCast=gnome
  '';
}
