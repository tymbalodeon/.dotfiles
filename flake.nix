{
  description = "Nix configuration";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    ...
  } @ inputs: let
    supportedSystems = ["x86_64-darwin" "x86_64-linux"];

    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems
      (system: f {pkgs = import nixpkgs {inherit system;};});
  in {
    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          alejandra
          pre-commit
        ];
      };
    });

    homeConfigurations = let
      hosts = ["benrosen" "work"];

      mkHost = hostName: {
        name = hostName;

        value = home-manager.lib.homeManagerConfiguration {
          modules = [./macos/${hostName}/home.nix];
          pkgs = nixpkgs.legacyPackages.x86_64-darwin;
        };
      };
    in
      builtins.listToAttrs (map (host: mkHost host) hosts);

    nixosConfigurations = let
      hosts = ["bumbirich" "ruzia"];

      mkHost = hostName: {
        name = hostName;

        value = nixpkgs.lib.nixosSystem {
          modules = [
            ./configuration.nix
            ./hardware-configurations/${hostName}-hardware-configuration.nix
            {networking.hostName = hostName;}
          ];

          specialArgs = {inherit inputs;};
        };
      };
    in
      builtins.listToAttrs (map (host: mkHost host) hosts);
  };
}
