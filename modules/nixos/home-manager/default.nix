{
  base16-helix,
  config,
  home-manager,
  hostName,
  hostType,
  lib,
  niri,
  nix-index-database,
  secrets,
  sops-nix,
  src,
  zk-graph,
  ...
}: {
  config = let
    cfg = config.home-manager;
  in {
    home-manager = {
      extraSpecialArgs = {
        inherit
          base16-helix
          hostName
          hostType
          niri
          nix-index-database
          secrets
          sops-nix
          src
          zk-graph
          ;
      };

      users.${config.nixos.username} = import cfg.homeFile;
    };
  };

  imports = [home-manager.nixosModules.home-manager];

  options.home-manager = with lib; {
    homeFile = mkOption {
      default = ../../../hosts/${hostType}/${hostName}/home.nix;
      type = types.path;
    };
  };
}
