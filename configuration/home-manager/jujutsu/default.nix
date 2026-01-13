{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    cfg = config.jujutsu;
  in {
    home.packages = [pkgs.jjui];

    programs.jujutsu = {
      enable = true;

      settings = {
        revsets.log = "@ | ancestors(remote_bookmarks().., 2) | trunk()";

        ui = {
          default-command = "log";
          pager = "less -FRX";
        };

        user = {
          email = cfg.email;
          name = cfg.name;
        };
      };
    };
  };

  options.jujutsu = let
    inherit (lib) mkOption types;

    str = types.str;
    user = import ../users;
  in {
    email = mkOption {
      default = user.email;
      type = str;
    };

    name = mkOption {
      default = user.name;
      type = str;
    };
  };
}
