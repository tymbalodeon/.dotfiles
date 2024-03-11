{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    # let

    # mkNixosSystems = hostName:
    #   nixpkgs.lib.nixosSystem {
    #     modules = [
    #       ./configuration.nix
    #       {
    #         inherit hostName;
    #       }
    #       # home-manager.nixosModules.default
    #     ];

    #     specialArgs = { inherit inputs; };
    #   };
    # in 
    {
      homeConfigurations."benrosen" =
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-darwin;
          modules = [ ./home/macos.nix ];
        };

      nixosConfigurations = let
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
      in builtins.listToAttrs [ (mkHost "bumbirich") (mkHost "ruzia") ];
      # {
      #   bumbirich = nixpkgs.lib.nixosSystem {
      #     modules = [
      #       ./configuration.nix
      #       ./hosts/bumbirich/hardware-configuration.nix
      #     ];
      #     specialArgs = {
      #       inherit inputs;
      #       networking.hostName = "bumbirich";
      #     };
      #   };

      # ruzia = nixpkgs.lib.nixosSystem {
      #   modules = [ ./configuration.nix { hostName = "ruzia"; } ];
      #   specialArgs = { inherit inputs; };
      # };
      # };
    };
}
