{
  description = "JLC Flake";

  # Mirrors host/programs.nix — lets `nix build`/`nix flake` hit binary caches
  # even before a rebuild. After `nh os switch`, system nix.conf is authoritative.
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://noctalia.cachix.org"
      "https://niri.cachix.org"
      "https://nvf.cachix.org"
      "https://notashelf.cachix.org"
      "https://zen-browser.cachix.org"
      "https://kevinpita.cachix.org"
      "https://ezkea.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.nixos-cuda.org"
      "https://nix-gaming.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://numtide.cachix.org"
      "https://cache.numtide.com"
      "https://codex-desktop-linux.cachix.org"
      "https://helix.cachix.org"
      "https://devenv.cachix.org"
      "https://chaotic-nyx.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "nvf.cachix.org-1:GMQWiUhZ6ux9D5CvFFMwnc2nFrUHTeGaXRlVBXo+naI="
      "notashelf.cachix.org-1:VTTBFNQWbfyLuRzgm2I7AWSDJdqAa11ytLXHBhrprZk="
      "zen-browser.cachix.org-1:z/QLGrEkiBYF/7zoHX1Hpuv0B26QrmbVBSy9yDD2tSs="
      "kevinpita.cachix.org-1:Cu9UtCDSfDq3/WDnI7N1N/LzAh90SPS+1R+nWao/hz0="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "codex-desktop-linux.cachix.org-1:nX/xy6AdK9hQE24A8ALGjkCKj2ObFmcnemiL5Cid4nk="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia.url = "github:noctalia-dev/noctalia/cachix";

    # No cache of its own, so following nixpkgs costs nothing and shares our Qt.
    qylock = {
      url = "github:Darkkal44/qylock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Must follow our nixpkgs: Electron dlopens the system Mesa from
    # /run/opengl-driver, and an older pinned glibc cannot load it
    # (GLIBC_2.43 not found -> blank window). Costs a local rebuild of the app.
    codex-desktop-linux = {
      url = "github:ilysenko/codex-desktop-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # claude-code, claude-desktop, grok-bot, codex, pi, omp, ccusage, herdr,
    # hermes-desktop. No nixpkgs follow so builds hit cache.numtide.com.
    llm-agents.url = "github:numtide/llm-agents.nix";

    # Second instance following our nixpkgs, used ONLY for claude-desktop and
    # hermes-desktop: the
    # Electron app dlopens system Mesa, and llm-agents' older glibc (2.42) cannot
    # load it (GLIBC_2.43 not found -> blank window). Everything else stays on
    # the cached llm-agents above.
    llm-agents-desktop = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";
  in {
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        {nixpkgs.hostPlatform = system;}
        ./configuration.nix
        inputs.home-manager.nixosModules.home-manager
        inputs.niri.nixosModules.niri
        inputs.noctalia.nixosModules.default
        inputs.qylock.nixosModules.default
      ];
    };
  };
}
