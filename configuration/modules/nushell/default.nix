{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = let
    cfg = config.nushell;
  in {
    home = {
      file = {
        "${cfg.configDirectory}/cloud.nu".source = ./cloud.nu;
        "${cfg.configDirectory}/f.nu".source = ./f.nu;
        "${cfg.configDirectory}/fonts.nu".source = ./fonts.nu;
        "${cfg.configDirectory}/music.nu".source = ./music.nu;
        "${cfg.configDirectory}/prompt.nu".source = ./prompt.nu;
        "${cfg.configDirectory}/src.nu".source = ./src.nu;
      };

      packages = [pkgs.fontconfig];
    };

    programs.nushell =
      {
        configFile.source = ./config.nu;
        enable = true;
        envFile.source = ./env.nu;

        plugins = with pkgs.nushellPlugins; [
          formats
          gstat
          polars
          query
        ];

        settings = {
          cursor_shape = {
            vi_insert = "line";
            vi_normal = "block";
          };

          datetime_format = {normal = "%A, %B %d, %Y %H:%M:%S";};
          edit_mode = "vi";
          show_banner = false;
        };

        shellAliases = {
          l = "ls --long";
          la = "ls --long --all";
          lsa = "ls --all";
          ssh = "nu '${./ssh.nu}'";
        };
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        environmentVariables = {
          FONTCONFIG_FILE = "${
            pkgs.makeFontsConf {fontDirectories = [pkgs.freefont_ttf];}
          }";
        };
      };
  };

  imports = [../jujutsu];

  options.nushell = with types; {
    configDirectory = lib.mkOption {
      default = ".config/nushell";
      description = "The value of `$nu.default-config-dir`";
      example = "Library/Application Support/nushell";
      type = str;
    };
  };
}
