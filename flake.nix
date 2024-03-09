{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    homeConfigurations."benrosen" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-darwin;
      modules = [ 
        ./home/home.nix
        ./home/macos.nix
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
