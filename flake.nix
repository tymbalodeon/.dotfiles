{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = 
      let
        modules = [ inputs.home-manager.nixosModules.default ];
        specialArgs = { inherit inputs; };
      in {
      desktop = nixpkgs.lib.nixosSystem {
        inherit specialArgs;

        modules = modules ++ [
          ./hosts/desktop/configuration.nix
        ];
      };

      laptop = nixpkgs.lib.nixosSystem {
        inherit specialArgs;

        modules = modules ++ [
          ./hosts/laptop/configuration.nix
        ];
      };
    };
  };
}
