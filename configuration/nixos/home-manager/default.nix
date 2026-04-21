{
  base16-helix,
  channel,
  config,
  home-manager,
  hostName,
  hostType,
  lib,
  nix-index-database,
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
          channel
          hostName
          hostType
          nix-index-database
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
      default = ../../hosts/${hostType}/${channel}/${hostName}/home.nix;
      type = types.path;
    };
  };
}
