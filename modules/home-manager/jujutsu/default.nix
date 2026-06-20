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
          inherit (cfg) email;
          inherit (cfg) name;
        };
      };
    };
  };

  options.jujutsu = let
    inherit (lib) mkOption types;

    inherit (types) str;
  in {
    email = mkOption {
      default = config.user.email;
      type = str;
    };

    name = mkOption {
      default = config.user.name;
      type = str;
    };
  };
}
