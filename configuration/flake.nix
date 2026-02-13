{
  inputs = {
    home-manager-25_05 = {
      inputs.nixpkgs.follows = "nixpkgs-25_05";
      url = "github:nix-community/home-manager/release-25.05";
    };

    home-manager-unstable = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:nix-community/home-manager";
    };

    nix-darwin-25_05 = {
      inputs.nixpkgs.follows = "nixpkgs-25_05";
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
    };

    nix-darwin-unstable = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:LnL7/nix-darwin";
    };

    nixgl = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:nix-community/nixGL";
    };

    nixpkgs-25_05.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    solaar = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:Svenum/Solaar-Flake/main";
    };

    src = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:tymbalodeon/src";
    };

    stylix-25_05 = {
      inputs.nixpkgs.follows = "nixpkgs-25_05";
      url = "github:nix-community/stylix/release-25.05";
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
    home-manager-25_05,
    home-manager-unstable,
    nix-darwin-25_05,
    nix-darwin-unstable,
    nixgl,
    nixpkgs-25_05,
    nixpkgs-unstable,
    solaar,
    src,
    stylix-25_05,
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
        ${hostName} = let
          nix-darwin =
            if channel == stable
            then nix-darwin-25_05
            else nix-darwin-unstable;

          stable = "25_05";
        in
          nix-darwin.lib.darwinSystem {
            system = "x86_64-darwin";

            modules = [
              ./hosts/${hostType}/${channel}/${hostName}/configuration.nix
            ];

            specialArgs = {
              inherit
                channel
                hostName
                hostType
                src
                zen-browser
                ;

              home-manager = let
                home-manager =
                  if channel == stable
                  then home-manager-25_05
                  else home-manager-unstable;
              in
                home-manager;

              stylix = let
                stylix =
                  if channel == stable
                  then stylix-25_05
                  else stylix-unstable;
              in
                stylix;
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
              src
              zen-browser
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
              src
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
