{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  # Enable networking
  networking.networkmanager.enable = true;
  #required for cloudflare-warp to work
  networking.firewall.checkReversePath = "loose";
  networking.firewall.allowedTCPPorts = [52984];
  networking.firewall.allowedUDPPorts = [52984];
  # Enables wireless support via wpa_supplicant.
  # networking.wireless.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  # Enable System Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  zramSwap.enable = true;

  #cloudflare warp
  # NOTE: don't enable services.resolved. WARP writes 127.0.2.2 straight into
  # /etc/resolv.conf, but with resolved on, nss-resolve bypasses that file and
  # WARP hangs at "Connecting" (connectivity-check.warp-svc never resolves).
  services.cloudflare-warp.enable = true;

  # Tailscale mesh VPN
  services.tailscale.enable = true;
  # Don't let MagicDNS take over /etc/resolv.conf. With no tailnet global
  # resolvers it forwards to the "system DNS" it captured, which was WARP's
  # 127.0.2.2 → no DNS at all whenever WARP was off.
  # VPS names are pinned in networking.hosts below.
  services.tailscale.extraSetFlags = ["--accept-dns=false"];
  networking.firewall.trustedInterfaces = ["tailscale0"];
  # wlp0s20f3 is also campus Wi-Fi, so don't trust it wholesale. Hotspot
  # (NM shared mode) only needs dnsmasq's DHCP + DNS; NAT forwarding is
  # unaffected since the NixOS firewall doesn't filter FORWARD.
  networking.firewall.interfaces.wlp0s20f3 = {
    allowedUDPPorts = [53 67];
    allowedTCPPorts = [53];
  };

  # Pin tailnet VPS hostnames (works even if MagicDNS is flaky)
  networking.hosts."100.73.232.54" = [
    "mumbai-oracle.tail7d48ad.ts.net"
  ];

  # Audio services - Pipewire by default
  services.pulseaudio.enable = false; #this is mutually exclusive w/ pipewire
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # enable Qt Configuuration, including theming
  qt = {
    enable = true;
  };

  # enable portals for spawning extra windows
  xdg.portal = {
    enable = true;

    config = {
      common = {
        default = [
          "gnome"
        ];
        "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
        "org.freedesktop.impl.portal.OpenURI" = ["gtk"];
      };
      niri = {
        default = [
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
        "org.freedesktop.impl.portal.OpenURI" = ["gtk"];
        "org.freedesktop.impl.portal.ScreenCast" = ["niri"];
        "org.freedesktop.impl.portal.Screenshot" = ["niri"];

        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Fonts
  fonts = {
    packages = with pkgs; [
      nerd-fonts.iosevka
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji-blob-bin
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [
          "Iosevka Nerd Font"
          "Noto Sans Mono CJK JP"
        ];
        sansSerif = [
          "Iosevka Nerd Font"
          "Noto Sans CJK JP"
        ];
        serif = [
          "Iosevka Nerd Font"
          "Noto Serif CJK JP"
        ];
      };
    };
  };

  # IME for Japanese Input
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc-ut
      fcitx5-gtk
    ];
  };

  environment.sessionVariables = {
    # Niri-Flake setting for electron apps
    NIXOS_OZONE_WL = "1";
  };

  # Nix CLI Helper tool, including flake paths for commands
  programs.nh = {
    enable = true;
    # So bare `nh os switch` works (sets NH_FLAKE)
    flake = "/home/crimxnhaze/blkedn";
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 5";
  };

  # Automatic Nix Store Management - Handling Garbage collection w/ nh's functions above
  nix = {
    optimise.automatic = true;
  };

  # General services
  # Grant user access to gaming mouse peripherals
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3554", ATTRS{idProduct}=="f503", MODE="0666"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3554", ATTRS{idProduct}=="fa09", MODE="0666"
    # AULA F75 keyboard (aula-f75 tool needs hidraw access)
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="258a", ATTRS{idProduct}=="010c", MODE="0666"
  '';

  services = {
    # GPU Conig Tool
    lact = {
      enable = true;
    };

    #thunar utils
    gvfs = {
      enable = true; # Mount, trash, and other functionalities
      package = lib.mkForce pkgs.gnome.gvfs; #full GVFS package for SMB browsing
    };
    tumbler.enable = true; # Thumbnail support for images

    samba = {
      enable = true;
      openFirewall = true;
      usershares = {
        enable = true;
        group = "samba";
      };
    };

    # Enable the X11 windowing system.
    xserver.enable = true;
    # Start IME on Wayland
    xserver.desktopManager.runXdgAutostartIfNone = true;

    # Enable Bluetooth control
    blueman.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;

    # Power management (required for Noctalia battery widget)
    upower.enable = true;
  };
}
