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

    wayland-pipewire-idle-inhibit.url = "github:rafaelrc7/wayland-pipewire-idle-inhibit";
  };

  outputs = {
    home-manager,
    nix-darwin,
    nixgl,
    nixpkgs,
    nixpkgs-stable,
    solaar,
    wayland-pipewire-idle-inhibit,
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
        ${hostName} = let
          system = "x86_64-darwin";
        in
          nix-darwin.lib.darwinSystem {
            inherit system;
            modules = [./systems/darwin/hosts/${hostName}/configuration.nix];

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

          modules = [./systems/linux/hosts/${hostName}/home.nix];
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        };
      })
      "linux";

    nixosConfigurations =
      mkHosts (hostName: {
        ${hostName} = nixpkgs.lib.nixosSystem {
          modules = [
            solaar.nixosModules.default
            ./systems/nixos/hosts/${hostName}/configuration.nix
            wayland-pipewire-idle-inhibit.nixosModules.default
          ];

          specialArgs = {
            inherit hostName inputs;
            isNixOS = true;
          };
        };
      })
      "nixos";
  };
}
