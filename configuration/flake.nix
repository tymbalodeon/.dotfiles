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
    nixpkgs-25_11.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    rofi-theme = {
      flake = false;
      url = "github:catppuccin/rofi";
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
  };

  outputs = {
    home-manager-25_05,
    home-manager-unstable,
    nix-darwin-25_05,
    nix-darwin-unstable,
    nixgl,
    nixpkgs-25_05,
    nixpkgs-25_11,
    nixpkgs-unstable,
    stylix-25_05,
    stylix-unstable,
    wayland-pipewire-idle-inhibit,
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

    getInputs = channel: {
      home-manager =
        if channel == "25_05"
        then home-manager-25_05
        else home-manager-unstable;

      nix-darwin =
        if channel == "25_05"
        then nix-darwin-25_05
        else nix-darwin-unstable;

      nixpkgs =
        if channel == "25_05"
        then nixpkgs-25_05
        else nixpkgs-unstable;

      stylix =
        if channel == "25_05"
        then stylix-25_05
        else stylix-unstable;
    };
  in {
    darwinConfigurations =
      mkHosts
      ({
        channel,
        hostType,
        hostName,
      }: {
        ${hostName} = let
          inherit
            (getInputs channel)
            home-manager
            nix-darwin
            stylix
            ;

          system = "x86_64-darwin";
        in
          nix-darwin.lib.darwinSystem {
            inherit system;

            modules = [
              ./hosts/${hostType}/${channel}/${hostName}/configuration.nix
              stylix.darwinModules.stylix
            ];

            specialArgs = {
              inherit
                channel
                hostName
                hostType
                home-manager
                ;

              pkgs-25_05 = import nixpkgs-25_05 {
                inherit system;

                config.allowUnfree = true;
              };
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
        ${hostName} = let
          inherit
            (getInputs channel)
            home-manager
            nixpkgs
            ;

          system = "x86_64-linux";
        in
          home-manager.lib.homeManagerConfiguration {
            extraSpecialArgs = {
              inherit
                channel
                hostType
                home-manager-unstable
                nixgl
                ;

              pkgs-25_05 = nixpkgs-25_05.legacyPackages.${system};
            };

            modules = [./hosts/${hostType}/${channel}/${hostName}/home.nix];
            pkgs = nixpkgs.legacyPackages.${system};
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
        ${hostName} = let
          inherit
            (getInputs channel)
            home-manager
            nixpkgs
            stylix
            ;
        in
          nixpkgs.lib.nixosSystem {
            modules = [
              ./hosts/${hostType}/${channel}/${hostName}/configuration.nix
              stylix.nixosModules.stylix
              wayland-pipewire-idle-inhibit.nixosModules.default
            ];

            specialArgs = {
              inherit
                channel
                hostName
                hostType
                home-manager
                ;

              pkgs-25_05 = import nixpkgs-25_11 {
                config.allowUnfree = true;
                system = "x86_64-linux";
              };
            };
          };
      })
      "nixos";
  };
}
