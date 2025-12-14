{
  inputs = {
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };

    nix-darwin = {
      inputs.nixpkgs.follows = "nixpkgs-stable";
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
    };

    nixgl.url = "github:nix-community/nixGL";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    rofi-theme = {
      flake = false;
      url = "github:catppuccin/rofi";
    };

    solaar = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Svenum/Solaar-Flake/main";
    };

    stylix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/stylix";
    };

    wayland-pipewire-idle-inhibit.url = "github:rafaelrc7/wayland-pipewire-idle-inhibit";
  };

  outputs = {
    home-manager,
    nix-darwin,
    nixgl,
    nixpkgs,
    nixpkgs-stable,
    solaar,
    stylix,
    wayland-pipewire-idle-inhibit,
    ...
  } @ inputs: let
    mkHosts = mkHost: hosts:
      builtins.foldl' (a: b: a // b) {}
      (map mkHost (builtins.attrNames (builtins.readDir ./hosts/${hosts})));
  in {
    darwinConfigurations =
      mkHosts
      (hostName: {
        ${hostName} = let
          system = "x86_64-darwin";
        in
          nix-darwin.lib.darwinSystem {
            inherit system;
            modules = [
              stylix.darwinModules.stylix
              ./hosts/darwin/${hostName}/configuration.nix
            ];

            specialArgs = {
              inherit hostName inputs;
              isNixOS = false;

              pkgs-stable = import nixpkgs-stable {
                inherit system;
                config.allowUnfree = true;
              };
            };
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

          modules = [./hosts/linux/standalone/${hostName}/home.nix];
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        };
      })
      "linux/standalone";

    nixosConfigurations =
      mkHosts (hostName: {
        ${hostName} = nixpkgs.lib.nixosSystem {
          modules = [
            solaar.nixosModules.default
            stylix.nixosModules.stylix
            ./hosts/linux/nixos/${hostName}/configuration.nix
            wayland-pipewire-idle-inhibit.nixosModules.default
          ];

          specialArgs = {
            inherit hostName inputs;
            isNixOS = true;

            pkgs-stable = import nixpkgs-stable {
              config.allowUnfree = true;
              system = "x86_64-linux";
            };
          };
        };
      })
      "linux/nixos";
  };
}
