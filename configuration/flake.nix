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

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nushell-syntax = {
      type = "github";
      owner = "stevenxxiu";
      repo = "sublime_text_nushell";
      flake = false;
    };
  };

  outputs = {
    home-manager,
    nix-darwin,
    nixpkgs,
    nushell-syntax,
    ...
  } @ inputs: {
    darwinConfigurations = let
      hosts = ["benrosen" "work"];

      mkHost = hostName: {
        name = hostName;

        value = nix-darwin.lib.darwinSystem {
          modules = [
            home-manager.darwinModules.home-manager
            ./darwin/${hostName}/home.nix
            ./darwin/${hostName}/configuration.nix
          ];
        };
      };
    in
      builtins.listToAttrs (map mkHost hosts);

    homeConfigurations = let
      hosts = ["benrosen" "work"];

      mkHost = hostName: {
        name = hostName;

        value = home-manager.lib.homeManagerConfiguration {
          modules = [./darwin/${hostName}/home.nix];
          pkgs = nixpkgs.legacyPackages.x86_64-darwin;

          extraSpecialArgs = {
            inherit nushell-syntax;
          };
        };
      };
    in
      builtins.listToAttrs (map mkHost hosts);

    nixosConfigurations = let
      hosts = ["bumbirich" "ruzia"];

      mkHost = hostName: {
        name = hostName;

        value = nixpkgs.lib.nixosSystem {
          modules = [
            ./nixos/${hostName}/configuration.nix
            ./nixos/hardware-configurations/${hostName}.nix
            {networking.hostName = hostName;}
          ];

          specialArgs = {inherit inputs;};
        };
      };
    in
      builtins.listToAttrs (map mkHost hosts);
  };
}
