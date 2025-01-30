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
  }: let
    getHosts = hostsDirectory:
      builtins.attrNames (builtins.readDir hostsDirectory);
  in {
    darwinConfigurations = let
      hosts = getHosts ./darwin/hosts;

      mkHost = hostName: {
        ${hostName} = nix-darwin.lib.darwinSystem {
          modules = [./darwin/hosts/${hostName}/configuration.nix];

          specialArgs = {
            inherit home-manager;
            inherit nushell-syntax;
          };

          system = "x86_64-darwin";
        };
      };
    in
      builtins.foldl' (a: b: a // b) {} (map mkHost hosts);

    nixosConfigurations = let
      hosts = getHosts ./nixos/hosts;

      mkHost = hostName: {
        name = hostName;

        value = nixpkgs.lib.nixosSystem {
          modules = [
            ./nixos/hosts/${hostName}/configuration.nix
            # TODO
            # import this in the configuration.nix?
            ./nixos/hosts/${hostName}/hardware-configuration.nix
            {networking.hostName = hostName;}
          ];

          specialArgs = {inherit home-manager;};
        };
      };
    in
      builtins.listToAttrs (map mkHost hosts);
  };
}
