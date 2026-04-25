{
  inputs = {
    base16-helix = {
      flake = false;
      url = "github:tinted-theming/base16-helix?dir=themes";
    };

    home-manager-25_05 = {
      inputs.nixpkgs.follows = "nixpkgs-25_05";
      url = "github:nix-community/home-manager/release-25.05";
    };

    home-manager-unstable = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:nix-community/home-manager";
    };

    musnix = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:musnix/musnix";
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

    nix-index-database = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:nix-community/nix-index-database";
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

    tsundeoku = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:tymbalodeon/tsundeoku";
    };

    wayland-pipewire-idle-inhibit = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:rafaelrc7/wayland-pipewire-idle-inhibit";
    };

    zk-graph = {
      flake = false;
      url = "sourcehut:~whynothugo/zk-graph";
    };
  };

  outputs = {
    base16-helix,
    home-manager-25_05,
    home-manager-unstable,
    musnix,
    nix-darwin-25_05,
    nix-darwin-unstable,
    nixgl,
    nix-index-database,
    nixpkgs-unstable,
    solaar,
    src,
    stylix-25_05,
    stylix-unstable,
    tsundeoku,
    wayland-pipewire-idle-inhibit,
    zk-graph,
    ...
  }: let
    inherit (nixpkgs-unstable.lib.lists) flatten;

    channels = hostType:
      builtins.attrNames (builtins.readDir ./hosts/${hostType});

    channelHosts = {
      channel,
      hostType,
    }:
      builtins.attrValues (
        builtins.mapAttrs
        (hostName: _: {inherit channel hostName hostType;})
        (builtins.readDir ./hosts/${hostType}/${channel})
      );

    hosts = hostType:
      flatten (
        map
        (channel: channelHosts {inherit channel hostType;})
        (channels hostType)
      );

    allHosts = flatten (
      map hosts
      (builtins.attrNames (builtins.readDir ./hosts))
    );

    mkHomeConfigurations = mkConfiguration:
      builtins.foldl' (a: b: a // b) {}
      (map mkConfiguration
        (map ({
          channel,
          hostName,
          hostType,
        }: {inherit channel hostName hostType;})
        allHosts));

    mkNixConfigurations = mkConfiguration: hostType:
      builtins.foldl' (a: b: a // b) {}
      (map mkConfiguration
        (map ({
          channel,
          hostName,
          hostType,
        }: {inherit channel hostName hostType;})
        (hosts hostType)));
  in {
    darwinConfigurations =
      mkNixConfigurations
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
            modules = [./darwin];

            specialArgs = {
              inherit
                base16-helix
                channel
                hostName
                hostType
                nix-index-database
                src
                tsundeoku
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

            system = "x86_64-darwin";
          };
      })
      "darwin";

    homeConfigurations =
      mkHomeConfigurations
      ({
        channel,
        hostType,
        hostName,
      }: let
        system = "x86_64-linux";
      in {
        ${hostName} = home-manager-unstable.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            inherit
              base16-helix
              channel
              hostName
              hostType
              home-manager-unstable
              nixgl
              nix-index-database
              src
              system
              zk-graph
              ;

            isHomeConfiguration = true;
            stylix = stylix-unstable;
          };

          modules = [./home-manager];
          pkgs = nixpkgs-unstable.legacyPackages.${system};
        };
      });

    nixosConfigurations =
      mkNixConfigurations
      ({
        channel,
        hostType,
        hostName,
      }: {
        ${hostName} = nixpkgs-unstable.lib.nixosSystem {
          modules = [./nixos];

          specialArgs = {
            inherit
              base16-helix
              channel
              hostName
              hostType
              musnix
              nix-index-database
              solaar
              src
              wayland-pipewire-idle-inhibit
              zk-graph
              ;

            isHomeConfiguration = false;
            stylix = stylix-unstable;
          };
        };
      })
      "nixos";
  };
}
