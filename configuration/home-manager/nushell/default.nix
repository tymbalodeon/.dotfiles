{
  channel,
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    cfg = config.nushell;
  in {
    home.packages = [pkgs.fontconfig];

    programs.nushell =
      {
        enable = true;
        envFile.source = ./env.nu;

        extraConfig = ''
          ${builtins.concatStringsSep
            "\n"
            (map
              (file: "use " + file)
              ((builtins.attrValues (
                  builtins.mapAttrs (file: _: ./scripts/${file})
                  (builtins.readDir ./scripts)
                ))
                ++ cfg.extraScripts))}
        '';

        extraEnv = let
          homeDir =
            if channel == "25_05"
            then "home-path"
            else "home-dir";

          prompt = pkgs.writeText "prompt.nu" ''
            def create_left_prompt [] {
              let home =  $nu.${homeDir}

              let dir = (
                if (
                 $env.PWD
                 | path split
                 | zip ($home | path split)
                 | all { $in.0 == $in.1 }
                ) {
                  ($env.PWD | str replace $home "~")
                } else {
                  $env.PWD
                }
              )

              let prompt = (
                $"($dir)"
                | str replace --all
                  (char path_sep)
                  $"(char path_sep)"
              )

              try {
                let branch = (
                  jj log
                    --no-graph
                    --revisions "ancestors(@)"
                    --template "bookmarks ++ '\n'"
                    err> /dev/null
                  | lines
                  | collect
                  | where {is-not-empty}
                  | first
                )

                let change_id = (
                  jj log
                    --no-graph
                    --revisions @
                    --template "change_id.shortest()"
                    err> /dev/null
                )

                $"($prompt) (ansi magenta)($branch) ($change_id)(ansi reset)\n"
              } catch {
                $prompt + $"\n"
              }
            }
          '';
        in ''
          source ${prompt}

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
    ../yazi
  ];

  options.nushell.extraScripts = let
    inherit (lib) mkOption types;
  in
    with types;
      mkOption {
        default = [];
        type = listOf path;
      };
}
