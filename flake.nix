{
  description = "Nix configuration";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, home-manager, nixpkgs, ... }@inputs: {
    homeConfigurations."benrosen" = home-manager.lib.homeManagerConfiguration {
      modules = [ ./macos/home.nix ];
      pkgs = nixpkgs.legacyPackages.x86_64-darwin;
    };

    nixosConfigurations = let
      hosts = [ "bumbirich" "ruzia" ];

      mkHost = hostName: {
        name = hostName;

        value = nixpkgs.lib.nixosSystem {
          modules = [
            ./configuration.nix
            ./hardware-configurations/${hostName}-hardware-configuration.nix
            { networking.hostName = hostName; }
          ];

          specialArgs = { inherit inputs; };
        };
      };
    in builtins.listToAttrs (map (host: mkHost host) hosts);
  };
}
