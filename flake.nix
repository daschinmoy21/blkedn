{
  description = "JLC Flake";

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

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    awww.url = "git+https://codeberg.org/LGFae/awww";

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

    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex-desktop-linux = {
      url = "github:ilysenko/codex-desktop-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kopuz = {
      url = "github:temidaradev/kopuz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    t3code-nix = {
      url = "github:Sawrz/t3code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-pi-coding-agent = {
      url = "github:peedrr/nix-pi-coding-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    niri,
    nvf,
    zen-browser,
    antigravity-nix,
    nix-pi-coding-agent,
    codex-cli-nix,
    codex-desktop-linux,
    kopuz,
    t3code-nix,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs system;
      zen-browser = zen-browser.packages.${system}.default;
    };
  in {
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        ./configuration.nix
        inputs.home-manager.nixosModules.home-manager
        inputs.niri.nixosModules.niri
        nix-pi-coding-agent.nixosModules.pi
      ];
    };

    homeConfigurations."crimxnhaze" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = {inherit inputs;};
      modules = [./home.nix];
    };
  };
}
