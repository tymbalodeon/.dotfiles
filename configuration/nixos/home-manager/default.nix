{
  base16-helix,
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
          base16-helix
          channel
          hostName
          hostType
          src
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
