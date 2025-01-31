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
  } @ inputs: let
    mkHosts = mkHost: kernel:
      builtins.foldl'
      (a: b: a // b)
      {}
      (map mkHost
        (builtins.attrNames (builtins.readDir ./kernels/${kernel}/hosts)));
  in {
    darwinConfigurations =
      mkHosts
      (hostName: {
        ${hostName} = nix-darwin.lib.darwinSystem {
          modules = [./kernels/darwin/hosts/${hostName}/configuration.nix];
          specialArgs = {inherit inputs;};
          system = "x86_64-darwin";
        };
      })
      "darwin";

    nixosConfigurations =
      mkHosts (hostName: {
        ${hostName} = nixpkgs.lib.nixosSystem {
          modules = [
            ./kernels/nixos/hosts/${hostName}/configuration.nix
            # TODO
            # import this in the configuration.nix?
            ./kernels/nixos/hosts/${hostName}/hardware-configuration.nix
            {networking.hostName = hostName;}
          ];

          specialArgs = {inherit inputs;};
        };
      })
      "nixos";
  };
}
