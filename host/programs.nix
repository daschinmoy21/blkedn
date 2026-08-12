{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  # Avoid package overrides here when possible — they miss binary caches and rebuild from source.
  system = pkgs.stdenv.hostPlatform.system;
in {
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      alsa-lib
      at-spi2-core
      cairo
      cups
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libappindicator-gtk3
      libdrm
      libgbm
      libglvnd
      libnotify
      libsecret
      libX11
      libxcb
      libXcomposite
      libXcursor
      libXdamage
      libXext
      libXfixes
      libXi
      libxkbcommon
      libXrandr
      libXrender
      libxshmfence
      libXScrnSaver
      libXtst
      mesa
      nspr
      nss
      pango
      stdenv.cc.cc
      systemd
      util-linux
      zlib
    ];
  };

  # See what of these can be put in home-manager
  environment.systemPackages = with pkgs; [
    # system tools
    grok-build
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
    appimage-run

    inputs.helium.packages.${system}.default
    discord
    uv
    virtiofsd
    stremio-linux-shell
    zed-editor
    cursor-cli
    feishin
    chromium

    pear-desktop

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
    podman-desktop # GUI for Podman
    lazydocker

    # package managers
    wget
    curl
    pciutils

    # hardware control
    lm_sensors #tool for scanning system fans

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
    ani-cli #CLI anime streaming
    youtube-tui
    tukai #terminal touch-typing practice
    sherlock #username checker
    scli #signal client

    # Creative Software

    obs-studio
    #olive-editor #video editor

    ffmpeg #video format converter

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
    tuigreet

    cloudflare-warp
    spotify
    ncspot
    cacert

    networkmanagerapplet
    power-profiles-daemon

    # migrated from nix profile
    blanket
    gnome-disk-utility
    mpv
    ripgrep
    socat
    t3code
    inputs.kopuz.packages.${system}.default

    # manage / query binary caches (`cachix use …` when experimenting)
    cachix
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

    eden.enable = true;

    virt-manager.enable = true;

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

  # Binary caches — prefer substitutes over local source builds.
  # Keys verified via https://app.cachix.org/api/v1/cache/<name>
  # flake.nix nixConfig mirrors this for pre-rebuild `nix` CLI usage.
  nix.settings = {
    # Keep rebuilds from OOMing 16G boxes (was auto / all cores)
    max-jobs = 1;
    cores = 4;

    # Prefer downloads; don't rebuild when a signed substitute exists
    always-allow-substitutes = true;
    builders-use-substitutes = true;
    max-substitution-jobs = 32;
    http-connections = 64;

    substituters = [
      # Official (must stay present)
      "https://cache.nixos.org"

      # Flake inputs / desktop stack
      "https://noctalia.cachix.org" # noctalia shell (cachix branch)
      "https://niri.cachix.org" # niri-flake
      "https://nvf.cachix.org" # notashelf/nvf
      "https://notashelf.cachix.org" # related nvf deps
      "https://zen-browser.cachix.org" # zen-browser-flake
      "https://kevinpita.cachix.org" # herdr-nix
      "https://kopuz.cachix.org" # kopuz (own nixpkgs pin)
      "https://ezkea.cachix.org" # AAGL / game launchers

      # Community / heavy rebuilds
      "https://nix-community.cachix.org" # home-manager & community pkgs
      "https://cuda-maintainers.cachix.org" # NVIDIA/CUDA stack
      "https://nix-gaming.cachix.org" # steam/proton adjacent
      "https://nixpkgs-wayland.cachix.org" # wayland packages
      "https://numtide.cachix.org" # numtide tooling
      "https://helix.cachix.org" # helix / evil-helix related
      "https://devenv.cachix.org" # devenv
      "https://chaotic-nyx.cachix.org" # large prebuild set
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "nvf.cachix.org-1:GMQWiUhZ6ux9D5CvFFMwnc2nFrUHTeGaXRlVBXo+naI="
      "notashelf.cachix.org-1:VTTBFNQWbfyLuRzgm2I7AWSDJdqAa11ytLXHBhrprZk="
      "zen-browser.cachix.org-1:z/QLGrEkiBYF/7zoHX1Hpuv0B26QrmbVBSy9yDD2tSs="
      "kevinpita.cachix.org-1:Cu9UtCDSfDq3/WDnI7N1N/LzAh90SPS+1R+nWao/hz0="
      "kopuz.cachix.org-1:J2X3AnAYhKTJW5S3aCLoA1ckonQXVNZMQvhZA0YAufw="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="

      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
    ];
  };
}
