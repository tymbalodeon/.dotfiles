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
      modules = [ ./home/macos.nix ];
    };

    nixosConfigurations = let
      hosts = [ "bumbirich" "ruzia" ];

      mkHost = hostName: {
        name = hostName;

        value = nixpkgs.lib.nixosSystem {
          modules = [
            ./configuration.nix
            ./hosts/${hostName}/hardware-configuration.nix
          ];

          specialArgs = {
            inherit inputs;
            networking.hostName = hostName;
          };
        };
      };
    in builtins.listToAttrs (map (host: mkHost host) hosts);
  };
}
