{
  inputs = {
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };

    nix-darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:LnL7/nix-darwin/master";
    };

    nixgl.url = "github:nix-community/nixGL";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # FIXME: pinned packages that are broken in more recent commits
    nixpkgs-kitty.url = "github:nixos/nixpkgs/dab3a6e781554f965bde3def0aa2fda4eb8f1708";
    nixpkgs-mpd.url = "github:nixos/nixpkgs/dab3a6e781554f965bde3def0aa2fda4eb8f1708";
    nixpkgs-nix-search-cli.url = "github:nixos/nixpkgs/dab3a6e781554f965bde3def0aa2fda4eb8f1708";

    solaar = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Svenum/Solaar-Flake/main";
    };
  };

  outputs = {
    home-manager,
    nix-darwin,
    nixgl,
    nixpkgs,
    solaar,
    ...
  } @ inputs: let
    mkHosts = mkHost: system:
      builtins.foldl' (a: b: a // b) {}
      (map mkHost
        (builtins.attrNames (builtins.readDir ./systems/${system}/hosts)));
  in {
    darwinConfigurations =
      mkHosts
      (hostName: {
        ${hostName} = nix-darwin.lib.darwinSystem {
          modules = [./systems/darwin/hosts/${hostName}/configuration.nix];

          specialArgs = {
            inherit hostName inputs;
            isNixOS = false;
          };

          system = "x86_64-darwin";
        };
      })
      "darwin";

    homeConfigurations =
      mkHosts
      (hostName: {
        ${hostName} = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            inherit inputs nixgl;
            isNixOS = false;
          };

          modules = [./systems/linux/hosts/${hostName}/home.nix];
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        };
      })
      "linux";

    nixosConfigurations =
      (mkHosts (hostName: {
          ${hostName} = nixpkgs.lib.nixosSystem {
            modules = [
              solaar.nixosModules.default
              ./systems/nixos/hosts/${hostName}/configuration.nix
            ];

            specialArgs = {
              inherit hostName inputs;
              isNixOS = true;
            };
          };
        })
        "nixos")
      // {
        iso = nixpkgs.lib.nixosSystem {
          modules = [./systems/nixos/hosts/iso/configuration.nix];
        };
      };
  };
}
