{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.nushell.configDirectory = lib.mkOption {
    type = lib.types.str;
    default = ".config/nushell";
    example = "Library/Application Support/nushell";
    description = "The value of `$nu.default-config-dir`";
  };

  config = let
    nu_default_config_dir = config.programs.nushell.configDirectory;
  in {
    home = {
      file = {
        "${nu_default_config_dir}/cloud.nu".source = ./cloud.nu;
        "${nu_default_config_dir}/colors.nu".source = ./colors.nu;
        "${nu_default_config_dir}/f.nu".source = ./f.nu;
        "${nu_default_config_dir}/fonts.nu".source = ./fonts.nu;
        "${nu_default_config_dir}/music.nu".source = ./music.nu;
        "${nu_default_config_dir}/prompt.nu".source = ./prompt.nu;
        "${nu_default_config_dir}/src.nu".source = ./src.nu;
        "${nu_default_config_dir}/ssh.nu".source = ./ssh.nu;
        "${nu_default_config_dir}/theme.nu".source = ./theme.nu;

        "${nu_default_config_dir}/theme-function.nu".source =
          if pkgs.stdenv.isDarwin
          then ./theme-function-darwin.nu
          else ./theme-function-linux.nu;

        "${nu_default_config_dir}/themes.toml".source = ./themes.toml;
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

        shellAliases =
          {
            l = "ls --long";
            la = "ls --long --all";
            lsa = "ls --all";

            ssh = let
              # FIXME
              defaultUser = import ../users/shared.nix;
              filename = "${nu_default_config_dir}/ssh.nu";

              homeDirectory =
                if pkgs.stdenv.isLinux
                then defaultUser.homeDirectoryLinux
                else defaultUser.homeDirectoryDarwin;
            in "nu '${builtins.toString homeDirectory}/${filename}'";
          }
          // (import ../aliases.nix);
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        environmentVariables = {
          FONTCONFIG_FILE = "${
            pkgs.makeFontsConf {fontDirectories = [pkgs.freefont_ttf];}
          }";
        };
      };
  };
}
