{
  description = "Nix configuration";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-elm = {
      url = "github:nixos/nixpkgs/3030f185ba6a4bf4f18b87f345f104e6a6961f34";
    };
  };

  outputs = {
    home-manager,
    nixpkgs,
    nixpkgs-elm,
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
          ansible-language-server
          deadnix
          nodePackages.jsonlint
          pre-commit
          python312Packages.pre-commit-hooks
          statix
          stylelint
          tokei
          yaml-language-server
          yamlfmt
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

          extraSpecialArgs = {
            pkgs-elm = import nixpkgs-elm {
              config.allowUnfree = true;
              system = "x86_64-darwin";
            };
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
            ./linux/configuration.nix
            ./linux/hardware-configurations/${hostName}.nix
            {networking.hostName = hostName;}
          ];

          specialArgs = {inherit inputs;};
        };
      };
    in
      builtins.listToAttrs (map mkHost hosts);
  };
}
