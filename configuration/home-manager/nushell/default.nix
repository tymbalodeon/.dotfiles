{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    cfg = config.nushell;
  in {
    home.packages = with pkgs; [
      fontconfig
      # TODO: only include on NixOS
      maestral
    ];

    programs.nushell =
      {
        enable = true;
        envFile.source = ./env.nu;

        extraConfig = ''
          const NU_LIB_DIRS = [${lib.concatStringsSep "\n" cfg.nuLibDirs}]

          ${builtins.concatStringsSep
            "\n"
            (map
              (file: "source " + file)
              (builtins.attrNames (builtins.readDir ./scripts)))}
        '';

        extraEnv = ''
          source ${./prompt.nu}

          $env.PROMPT_COMMAND = {|| create_left_prompt}
          $env.PROMPT_COMMAND_RIGHT = {|| null}
          $env.PROMPT_INDICATOR_VI_INSERT = "> "
          $env.PROMPT_INDICATOR_VI_NORMAL = ">> "
          $env.PROMPT_MULTILINE_INDICATOR = "::: "
        '';

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

          hooks.env_change.PWD = [
            ''
              {
                # TODO: auto-pull from https://github.com/nushell/nu_scripts/blob/main/nu-hooks/nu-hooks/direnv/config.nu

                if (which direnv | is-empty) {
                    return
                  }

                  direnv export json
                  | from json
                  | default {}
                  | load-env

                  $env.PATH = ($env.PATH | split row (char env_sep))
              }
            ''
          ];

          show_banner = false;
        };

        shellAliases = {
          l = "ls --long";
          la = "ls --long --all";
          lsa = "ls --all";
          ssh = "nu '${./scripts/ssh.nu}'";
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

  imports = [
    ../fzf
    ../jujutsu
    # TODO: only include on NixOS
    ../rclone
    ../yazi
  ];

  options.nushell.nuLibDirs = let
    inherit (lib) mkOption types;
  in
    with types;
      mkOption {
        default = [./scripts];
        type = listOf path;
      };
}
