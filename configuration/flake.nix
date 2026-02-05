{
  inputs = {
    home-manager-unstable = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:nix-community/home-manager";
    };

    nix-darwin-unstable = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:LnL7/nix-darwin";
    };

    nixgl = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:nix-community/nixGL";
    };

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    solaar = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:Svenum/Solaar-Flake/main";
    };

    stylix-unstable = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:nix-community/stylix";
    };

    wayland-pipewire-idle-inhibit = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:rafaelrc7/wayland-pipewire-idle-inhibit";
    };

    zen-browser = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:youwen5/zen-browser-flake";
    };
  };

  outputs = {
    home-manager-unstable,
    nix-darwin-unstable,
    nixgl,
    nixpkgs-unstable,
    solaar,
    stylix-unstable,
    wayland-pipewire-idle-inhibit,
    zen-browser,
    ...
  }: let
    getChannels = hostType:
      builtins.attrNames (builtins.readDir ./hosts/${hostType});

    getChannelHosts = {
      channel,
      hostType,
    }:
      builtins.attrValues (
        builtins.mapAttrs
        (hostName: _: {inherit channel hostName hostType;})
        (builtins.readDir ./hosts/${hostType}/${channel})
      );

    getHosts = hostType:
      nixpkgs-unstable.lib.lists.flatten (
        map
        (channel: getChannelHosts {inherit channel hostType;})
        (getChannels hostType)
      );

    mkHosts = mkHost: hostType:
      builtins.foldl' (a: b: a // b) {}
      (map mkHost
        (map ({
          channel,
          hostName,
          hostType,
        }: {inherit channel hostName hostType;})
        (getHosts hostType)));
  in {
    darwinConfigurations =
      mkHosts
      ({
        channel,
        hostType,
        hostName,
      }: {
        ${hostName} = nix-darwin-unstable.lib.darwinSystem {
          system = "x86_64-darwin";

          modules = [
            ./hosts/${hostType}/${channel}/${hostName}/configuration.nix
          ];

          specialArgs = {
            inherit
              channel
              hostName
              hostType
              ;

            home-manager = home-manager-unstable;
            stylix = stylix-unstable;
          };
        };
      })
      "darwin";

    homeConfigurations =
      mkHosts
      ({
        channel,
        hostType,
        hostName,
      }: {
        ${hostName} = home-manager-unstable.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            inherit
              channel
              hostType
              home-manager-unstable
              nixgl
              ;
          };

          modules = [./hosts/${hostType}/${channel}/${hostName}/home.nix];
          pkgs = nixpkgs-unstable.legacyPackages.x86_64-linux;
        };
      })
      "home-manager";

    nixosConfigurations =
      mkHosts
      ({
        channel,
        hostType,
        hostName,
      }: {
        ${hostName} = nixpkgs-unstable.lib.nixosSystem {
          modules = [
            ./hosts/${hostType}/${channel}/${hostName}/configuration.nix
          ];

          specialArgs = {
            inherit
              channel
              hostName
              hostType
              solaar
              wayland-pipewire-idle-inhibit
              zen-browser
              ;

            home-manager = home-manager-unstable;
            stylix = stylix-unstable;
          };
        };
      })
      "nixos";
  };
}
