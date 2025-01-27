{
  inputs = let
    nixpkgsUrl = "github:nixos/nixpkgs/nixos-unstable";
  in {
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };

    nixpkgs.url = nixpkgsUrl;
    nixpkgs-darwin.url = nixpkgsUrl;

    nushell-syntax = {
      type = "github";
      owner = "stevenxxiu";
      repo = "sublime_text_nushell";
      flake = false;
    };
  };

  outputs = {
    home-manager,
    nixpkgs,
    nixpkgs-darwin,
    nushell-syntax,
    ...
  } @ inputs: {
    homeConfigurations = let
      hosts = ["benrosen" "work"];

      mkHost = hostName: {
        name = hostName;

        value = home-manager.lib.homeManagerConfiguration {
          modules = [./darwin/${hostName}/home.nix];
          pkgs = nixpkgs-darwin.legacyPackages.x86_64-darwin;

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
