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
    stylix,
    wayland-pipewire-idle-inhibit,
    ...
  } @ inputs: let
    mkHosts = mkHost: hostType:
      builtins.foldl' (a: b: a // b) {}
      (map mkHost (builtins.attrNames (builtins.readDir ./hosts/${hostType})));
  in {
    darwinConfigurations = let
      hostType = "darwin";
    in
      mkHosts
      (hostName: {
        ${hostName} = let
          system = "x86_64-darwin";
        in
          nix-darwin.lib.darwinSystem {
            inherit system;

            modules = [
              ./hosts/${hostType}/${hostName}/configuration.nix
              stylix.darwinModules.stylix
            ];

            specialArgs = {
              inherit hostName inputs;

              hostType = hostType;
              isNixOS = false;

              pkgs-stable = import nixpkgs-stable {
                inherit system;

                config.allowUnfree = true;
              };
            };
          };
      })
      hostType;

    homeConfigurations = let
      hostType = "home-manager";
    in
      mkHosts
      (hostName: {
        ${hostName} = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            inherit inputs nixgl;

            isNixOS = false;
            pkgs-stable = nixpkgs-stable.legacyPackages.x86_64-linux;
          };

          modules = [./hosts/${hostType}/${hostName}/home.nix];
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        };
      })
      hostType;

    nixosConfigurations = let
      hostType = "nixos";
    in
      mkHosts (hostName: {
        ${hostName} = nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/${hostType}/${hostName}/configuration.nix
            stylix.nixosModules.stylix
            wayland-pipewire-idle-inhibit.nixosModules.default
          ];

          specialArgs = {
            inherit hostName inputs;

            hostType = hostType;
            isNixOS = true;

            pkgs-stable = import nixpkgs-stable {
              config.allowUnfree = true;
              system = "x86_64-linux";
            };
          };
        };
      })
      hostType;
  };
}
