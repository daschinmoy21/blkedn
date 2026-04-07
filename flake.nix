{
  description = "JLC Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

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

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.quickshell.follows = "quickshell"; # Use same quickshell version
    };

    matugen = {
      url = "github:/InioX/Matugen";
    }; #tool to grab color-scheme from wallpapers

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    textfox = {
      url = "github:adriankarlen/textfox";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #affinity-nix.url = "github:mrshmllow/affinity-nix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    niri,
    nixvim,
    zen-browser,
    antigravity-nix,
    microvm,
    #affinity-nix,
    ...
  } @ inputs: let
    # users = "jlc";
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    specialArgs = {
      inherit inputs system;
      zen-browser = zen-browser.packages.${system}.default;
    };
  in {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    nixosConfigurations.nixos =
      nixpkgs.lib.nixosSystem
      {
        system = system;
        specialArgs = specialArgs;
        modules = [
          ./configuration.nix

          inputs.home-manager.nixosModules.home-manager
          inputs.noctalia.nixosModules.default
          inputs.niri.nixosModules.niri
          {
            nixpkgs.overlays = [niri.overlays.niri];
          }
          {
            #environment.systemPackages = [affinity-nix.packages.x86_64-linux.v3];
          }
        ];
      };

    homeConfigurations = let
      # pkgs = nixpkgs.legacyPackages.${system};
      config = {
        inherit pkgs;
        extraSpecialArgs = specialArgs;
      };
    in {
      homeConfigurations = {
        "crimxnhaze" =
          home-manager.lib.homeManagerConfiguration
          {
            pkgs = pkgs;
            modules = [
              ./home.nix
            ];
          };
      };
    };
  };
}
