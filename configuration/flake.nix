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
    ...
  } @ inputs: let
    mkHosts = mkHost: system:
      builtins.foldl'
      (a: b: a // b)
      {}
      (map mkHost
        (builtins.attrNames (builtins.readDir ./systems/${system}/hosts)));
  in {
    darwinConfigurations =
      mkHosts
      (hostName: {
        ${hostName} = nix-darwin.lib.darwinSystem {
          modules = [./systems/darwin/hosts/${hostName}/configuration.nix];
          specialArgs = {inherit inputs;};
          system = "x86_64-darwin";
        };
      })
      "darwin";

    homeConfigurations =
      mkHosts
      (hostName: {
        ${hostName} = home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = {inherit inputs;};
          modules = [./systems/linux/hosts/${hostName}/home.nix];
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        };
      })
      "linux";

    nixosConfigurations =
      mkHosts (hostName: {
        ${hostName} = nixpkgs.lib.nixosSystem {
          modules = [
            ./systems/nixos/hosts/${hostName}/configuration.nix
            {networking.hostName = hostName;}
          ];

          specialArgs = {inherit inputs;};
        };
      })
      "nixos";
  };
}
