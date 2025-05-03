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

  config = {
    home.file = let
      nu_default_config_dir = config.programs.nushell.configDirectory;
    in {
      "${nu_default_config_dir}/aliases.nu".source = ./aliases.nu;
      "${nu_default_config_dir}/cloud.nu".source = ./cloud.nu;
      "${nu_default_config_dir}/colors.nu".source = ./colors.nu;
      "${nu_default_config_dir}/f.nu".source = ./f.nu;
      "${nu_default_config_dir}/prompt.nu".source = ./prompt.nu;
      "${nu_default_config_dir}/src.nu".source = ./src.nu;
      "${nu_default_config_dir}/theme.nu".source = ./theme.nu;

      "${nu_default_config_dir}/theme-function.nu".source =
        if pkgs.stdenv.isDarwin
        then ./theme-function-darwin.nu
        else ./theme-function-linux.nu;

      "${nu_default_config_dir}/themes.toml".source = ./themes.toml;
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
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        extraEnv = ''
          $env.FONTCONFIG_FILE = "${
            pkgs.makeFontsConf {fontDirectories = [pkgs.freefont_ttf];}
          }"
        '';
      };
  };
}
