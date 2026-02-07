{
  channel,
  config,
  home-manager,
  hostType,
  lib,
  src,
  zen-browser,
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
          zen-browser
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
