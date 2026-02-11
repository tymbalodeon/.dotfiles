{
  channel,
  config,
  home-manager,
  hostName,
  hostType,
  lib,
  src,
  ...
}: {
  config = let
    cfg = config.home-manager;
  in {
    home-manager = {
      extraSpecialArgs = {
        inherit
          channel
          hostType
          src
          ;
      };

      users.${config.darwin.username} = import cfg.homeFile;
    };
  };

  imports = [home-manager.darwinModules.home-manager];

  options.home-manager = with lib; {
    homeFile = mkOption {
      default = ../../hosts/${hostType}/${channel}/${hostName}/home.nix;
      type = types.path;
    };
  };
}
