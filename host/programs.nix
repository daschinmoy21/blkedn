{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  blender = pkgs.blender.override {hipSupport = true;};
in {

  # See what of these can be put in home-manager
  environment.systemPackages = with pkgs; [
    # system tools
    bluez-headers # bluetooth enabling
    pulseaudio # provides pactl
    alejandra #nix language formatting
    nix-init #tool of building packages
    xarchiver #GTK frontend for 7zip
    glibc #c language library
    dosfstools #create and check V/FAT file systems
    ntfs3g # NTFS handling
    gnumake # 'make' commands
    wev #find keystrokes for wayland compsitor; helpful when altering keybinds
    nix-output-monitor
    nvd
    opencode
    code-cursor-fhs

    inputs.helium.packages.${system}.default
    discord
    uv
    virtiofsd
    stremio-linux-shell
    zed-editor
    cursor-cli
    feishin

    btop
    heroic
    yazi
    obsidian
    element-desktop

    # scripting
    nodejs_22

    # git
    git
    gh
    git-crypt #directory and file encryption
    gh #github cli tools
    lazydocker

    # package managers
    git
    wget
    curl
    pciutils

    # hardware control
    lm_sensors #tool for scanning system fans
    lact #GPU config tool
    amdctl #CPU config tool

    # display shenangians
    xdg-utils
    xdg-desktop-portal-gtk
    xdg-desktop-portal-xapp
    xwayland-satellite
    cmatrix

    # general use and media

    vlc
    qbittorrent
    nicotine-plus # soulseek client
    picard # music metadata editor
    element-desktop #matrix client
    ani-cli #CLI anime streaming
    youtube-tui
    tukai #terminal touch-typing practice
    sherlock #username checker
    scli #signal client

    # Creative Software

    obs-studio
    #olive-editor #video editor

    ffmpeg #video format converter
    obsidian # Notes organization

    # productivity
    xournalpp #Notetaking
    onlyoffice-desktopeditors # Office Suite

    hoard #CLI Command Organizer
    gtt #google translate tui
    tlrc #simiplified man pages written in rust

    # game/3d tools
    protonup-ng #installed proton GE
    protonup-qt #GUI for managing Proton GE
    winetricks #etxra wine DLLs

    mangohud #process overlay
    lutris

    # styling tools
    catppuccin-cursors.frappeDark
    font-manager
    adwaita-icon-theme
    dracula-icon-theme
    kdePackages.fcitx5-configtool # IME Config tool
    inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
    tuigreet

    cloudflare-warp
    spotify
    ncspot
    chromium
    cacert

    networkmanagerapplet
    power-profiles-daemon

    # migrated from nix profile
    blanket
    gnome-disk-utility
    mpv
    ripgrep
    socat
    inputs.codex-cli-nix.packages.${system}.default
    inputs.kopuz.packages.${system}.default
    inputs.t3code-nix.packages.${system}.t3code
  ];

  # Enable programs defined by Home Manager modules.

  programs = {
    fish.enable = true;
    direnv = {
      enable = true;
      direnvrcExtra = ''

        echo "loaded direnv!"
      '';
    };
    coolercontrol.enable = true;

    steam.enable = true;
    steam.gamescopeSession.enable = true;
    gamemode.enable = true;

    virt-manager.enable = true;
    dms-shell = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
      enableSystemMonitoring = true;
      enableVPN = true;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;
      quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
    };

    dconf.enable = true;
    xfconf.enable = true; #allow Thunar configs
    thunar = {
      enable = true;
      plugins = [
        pkgs.thunar-volman
        pkgs.thunar-archive-plugin
      ];
    };

    # Use the nixpkgs-packaged Niri instead of the flake-provided variants.
    niri.enable = true;
    niri.package = pkgs.niri;
  };

  # cachix sources

  nix.settings = {
    substituters = [
      "https://ezkea.cachix.org"
      #"https://cache.garnix.io"
    ];

    trusted-public-keys = [
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
      #"cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };
}
