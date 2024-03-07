{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }@inputs: {
    darwinConfigurations."Bens-iMac" = let
      configuration = {
        environment.systemPackages = with nixpkgs; [ ];
        nix.settings.experimental-features = "nix-command flakes";
        nixpkgs.hostPlatform = "x86_64-darwin";
        programs.zsh.enable = true;
        services.nix-daemon.enable = true;

        system = {
          configurationRevision = self.rev or self.dirtyRev or null;
          stateVersion = 4;
        };
      };
    in nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.rrosen = import ./hosts/macos/home.nix;
          };
        }
      ];
    };

    nixosConfigurations = let
      modules = [ home-manager.nixosModules.default ];
      specialArgs = { inherit inputs; };
    in {
      desktop = nixpkgs.lib.nixosSystem {
        inherit specialArgs;

        modules = modules ++ [ ./hosts/desktop/configuration.nix ];
      };

      laptop = nixpkgs.lib.nixosSystem {
        inherit specialArgs;

        modules = modules ++ [ ./hosts/laptop/configuration.nix ];
      };
    };
  };
}
