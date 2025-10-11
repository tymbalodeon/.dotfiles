{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.jujutsu;
in {
  config = {
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

  options.jujutsu = with types; let
    user = import ../../modules/users/user.nix;
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
