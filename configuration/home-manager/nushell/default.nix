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
    home = let
      autoload_directory = (
        lib.removeSuffix "\n" (
          lib.readFile "${
            pkgs.runCommand "nushell-user-autoload-dirs"
            {buildInputs = [pkgs.nushell];}
            "echo `nu --commands 'print (
                $nu.user-autoload-dirs
                | first
                | path split
                | drop nth 0..1
                | path join
                | str trim
            )'` > $out"
          }"
        )
      );
    in {
      file."${autoload_directory}/f.nu".source = pkgs.writeText "f.nu" ''
        def get-path [directory?: string] {
          let directory = if ($directory | is-empty) {
            $env.HOME
          } else {
            $directory
            | path expand
          }

          let type = if ($directory | is-empty) {
            "directory"
          } else {
            if ($directory | path type) == dir {
              "file"
            } else {
              "directory"
            }
          }

          $directory
          | path join (
              fd --hidden "" $directory
              | str replace --all $"($directory)/" ""
              | lines
              | sort
              | to text
              | fzf --exact --scheme path
            )
        }

        # Search for files interactively
        def --env f [
          directory?: string # Search this directory
        ] {
          let path = (get-path $directory)

          if ($path | path type) == dir {
            cd $path
          } else {
            start-process xdg-open $path
          }
        }

        # Search for files interactively and `cd` to directories, or parents of files
        def --env "f cd" [
          directory?: string # Search this directory
        ] {
          let path = (get-path $directory)

          if ($path | path type) == dir {
            cd $path
          } else {
            cd ($path | path dirname)
          }
        }

        # Search for files interactively and edit them with $EDITOR
        def "f edit" [
          directory?: string # Search this directory
        ] {
          let path = (get-path $directory)

          ^$env.EDITOR $path

          try {
            $path
            | path relative-to (pwd)
          } catch {
            $path
          }
        }

        # Search for files interactively and open them
        def "f open" [
          directory?: string # Search this directory
          --application (-a): string # The command to open the file with
        ] {
          let path = (get-path $directory)

          if ($application | is-not-empty) {
            run-external $application $path
          } else {
            start-process xdg-open $path
          }
        }
      '';
      packages = [pkgs.fontconfig];
    };

    programs.nushell =
      {
        enable = true;
        envFile.source = ./env.nu;

        extraConfig = ''
          ${
            builtins.concatStringsSep "\n"
            (
              map (file: "source ${file}")
              ((
                  builtins.attrValues (
                    builtins.mapAttrs (file: _: ./scripts/${file})
                    (builtins.readDir ./scripts)
                  )
                )
                ++ cfg.extraScripts)
            )
          }
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
