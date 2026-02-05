{
  channel,
  config,
  home-manager,
  hostName,
  hostType,
  lib,
  ...
}: {
  config = let
    cfg = config.home-manager;
  in {
    home-manager = {
      extraSpecialArgs = {
        inherit
          channel
          hostName
          hostType
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
