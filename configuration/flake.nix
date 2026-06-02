{
  inputs = {
    base16-helix = {
      flake = false;
      url = "github:tinted-theming/base16-helix?dir=themes";
    };

    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };

    musnix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:musnix/musnix";
    };

    nixgl = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nixGL";
    };

    nix-index-database = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nix-index-database";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    npc = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:samestep/npc";
    };

    solaar = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Svenum/Solaar-Flake/main";
    };

    src = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "git+ssh://git@codeberg.org/tymbalodeon/src.git";
    };

    stylix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/stylix";
    };

    wayland-pipewire-idle-inhibit = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:rafaelrc7/wayland-pipewire-idle-inhibit";
    };

    zk-graph = {
      flake = false;
      url = "sourcehut:~whynothugo/zk-graph";
    };
  };

  outputs = {
    base16-helix,
    home-manager,
    musnix,
    nixgl,
    nix-index-database,
    nixpkgs,
    npc,
    solaar,
    src,
    stylix,
    wayland-pipewire-idle-inhibit,
    zk-graph,
    ...
  }: let
    getHosts = hostType:
      builtins.attrValues (
        builtins.mapAttrs
        (hostName: _: {inherit hostName hostType;})
        (builtins.readDir ./hosts/${hostType})
      );

    mkHosts = mkHost: hostType:
      builtins.foldl' (a: b: a // b) {}
      (map mkHost
        (map ({
          hostName,
          hostType,
        }: {inherit hostName hostType;})
        (getHosts hostType)));
  in {
    homeConfigurations =
      mkHosts
      ({
        hostType,
        hostName,
      }: let
        system = "x86_64-linux";
      in {
        ${hostName} = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            inherit
              hostName
              hostType
              home-manager
              nixgl
              nix-index-database
              npc
              src
              system
              zk-graph
              ;
          };

          modules = [./home-manager];
          pkgs = nixpkgs.legacyPackages.${system};
        };
      })
      "home-manager";

    nixosConfigurations =
      mkHosts
      ({
        hostType,
        hostName,
      }: {
        ${hostName} = nixpkgs.lib.nixosSystem {
          modules = [./nixos];

          specialArgs = {
            inherit
              base16-helix
              home-manager
              hostName
              hostType
              musnix
              nix-index-database
              npc
              solaar
              src
              stylix
              wayland-pipewire-idle-inhibit
              zk-graph
              ;
          };
        };
      })
      "nixos";
  };
}
