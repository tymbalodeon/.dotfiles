{
  config,
  lib,
  ...
}: {
  config = let
    cfg = config.displayManager;
  in {
    services.displayManager = {
      defaultSession = cfg.defaultSession;
      ly.enable = true;
    };
  };

  options.displayManager.defaultSession = let
    inherit (lib) mkOption types;
  in
    mkOption {
      default = "niri";
      type = types.str;
    };
}
