{
  config,
  lib,
  musnix,
  pkgs,
  ...
}: {
  config = let
    cfg = config.musnix;
  in {
    musnix = {
      enable = true;

      kernel = {
        packages = cfg.kernelPackages;
        realtime = true;
      };
    };
  };

  imports = [musnix.nixosModules.musnix];

  options.musnix.kernelPackages = with lib;
    mkOption {
      default = pkgs.linuxPackages;
      type = types.attrs;
    };
}
