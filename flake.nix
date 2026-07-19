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

    niri = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "git+https://codeberg.org/BANanaD3V/niri-nix";
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

    secrets = {
      flake = false;
      url = "git+ssh://git@github.com/tymbalodeon/secrets.git?dir=secrets&shallow=1";
    };

    solaar = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Svenum/Solaar-Flake/main";
    };

    sops-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/sops-nix";
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
    niri,
    nixgl,
    nix-index-database,
    nixpkgs,
    secrets,
    solaar,
    sops-nix,
    src,
    stylix,
    wayland-pipewire-idle-inhibit,
    zk-graph,
    ...
  }: let
    commonInputs = {
      inherit
        nix-index-database
        src
        zk-graph
        ;
    };

    getHosts = isNixOS: let
      hostType =
        if isNixOS
        then "nixos"
        else "home-manager";
    in
      builtins.attrValues (
        builtins.mapAttrs
        (hostName: _: {inherit hostName hostType;})
        (builtins.readDir ./hosts/${hostType})
      );

    mkConfigurations = {isNixOS}: let
      args = {
        hostName,
        hostType,
      }: let
        commonArgs = commonInputs // {inherit hostName hostType;};
      in
        if isNixOS
        then {
          inherit modules;

          specialArgs =
            commonArgs
            // {
              inherit
                base16-helix
                home-manager
                musnix
                niri
                secrets
                solaar
                sops-nix
                stylix
                wayland-pipewire-idle-inhibit
                ;
            };
        }
        else
          (
            let
              system = "x86_64-linux";
            in {
              inherit modules;

              extraSpecialArgs =
                commonArgs
                // {
                  inherit
                    home-manager
                    nixgl
                    system
                    ;
                };

              pkgs = nixpkgs.legacyPackages.${system};
            }
          );

      configuration =
        if isNixOS
        then nixpkgs.lib.nixosSystem
        else home-manager.lib.homeManagerConfiguration;

      modules =
        if isNixOS
        then [./modules/nixos]
        else [./modules/home-manager];
    in
      mkHosts
      {
        inherit isNixOS;

        mkHost = {
          hostType,
          hostName,
        }: {
          ${hostName} = configuration (args {inherit hostName hostType;});
        };
      };

    mkHosts = {
      isNixOS,
      mkHost,
    }:
      builtins.foldl' (a: b: a // b) {}
      (map mkHost
        (map ({
          hostName,
          hostType,
        }: {inherit hostName hostType;})
        (getHosts isNixOS)));
  in {
    homeConfigurations = mkConfigurations {isNixOS = false;};
    nixosConfigurations = mkConfigurations {isNixOS = true;};
  };
}
