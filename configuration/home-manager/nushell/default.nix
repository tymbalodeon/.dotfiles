{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    autoload_directory = lib.removeSuffix "\n" (
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
    );

    cfg = config.nushell;
  in {
    home = {
      file =
        builtins.listToAttrs (
          map
          (script: let
            filename =
              if builtins.hasAttr "source" script && script.source != null
              then baseNameOf script.source
              else if builtins.hasAttr "name" script && script.name != null
              then "${script.name}.nu"
              else null;

            includes =
              if builtins.hasAttr "includes" script
              then
                lib.strings.join "\n" (
                  map (include: "source ${cfg.autoloadDirectory}/${include}.nu")
                  script.includes
                )
              else "";

            originalText =
              if builtins.hasAttr "source" script && script.source != null
              then builtins.readFile script.source
              else script.text;

            text =
              if includes != ""
              then includes + "\n\n" + originalText
              else originalText;
          in {
            name = "${autoload_directory}/${filename}";
            value = {
              inherit text;

              force = true;
            };
          })
          ([
              {
                includes = ["start-process"];
                source = ./f.nu;
              }

              {source = ./ssh.nu;}
              {source = ./start-process.nu;}
            ]
            ++ cfg.extraScripts)
        )
        // {
          ".cache/devenv/hook.nu".source =
            pkgs.runCommand "devenv-hook" {
              buildInputs = [pkgs.devenv];
            } ''
              devenv hook nu > $out
            '';
        };

      packages = [pkgs.fontconfig];
    };

    nushell.autoloadDirectory =
      lib.mkForce "${config.home.homeDirectory}/${autoload_directory}";

    programs.nushell = {
      configFile.source = ./config.nu;
      enable = true;

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
        ssh = "nu '${./ssh.nu}'";
      };
    };
  };

  imports = [
    ../fzf
    ../jujutsu
    ../yazi
  ];

  options.nushell = let
    inherit (lib) mkOption types;
  in
    with types; {
      autoloadDirectory = mkOption {
        type = str;
      };

      extraScripts = mkOption {
        type = listOf (submodule {
          options = {
            includes = mkOption {
              type = listOf str;
            };

            name = mkOption {
              type = str;
            };

            source = mkOption {
              type = nullOr path;
            };

            text = mkOption {
              type = nullOr str;
            };
          };
        });
      };
    };
}
