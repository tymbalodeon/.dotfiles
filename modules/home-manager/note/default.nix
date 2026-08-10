{
  config,
  lib,
  pkgs,
  zk-graph,
  ...
}: let
  journalDirectory = "journal";
in {
  config = let
    cfg = config.nb;
  in {
    home = {
      activation.nb = let
        script =
          pkgs.writeScript "activate-note"
          (
            # nushell
            ''
              def --wrapped git [...args: string] {
                ${lib.getExe pkgs.git} ...$args
              }

              def remotes [] {
                '${builtins.toJSON cfg.remotes}'
                | from json
              }

            ''
            + builtins.readFile ./home-activation.nu
          );
      in
        lib.hm.dag.entryAfter ["writeBoundary"] ''
          run ${lib.getExe pkgs.nushell} "${script}"
        '';

      file = {
        ".nb/.plugins/csv.nb-plugin".source = ./csv.nb-plugin;
        ".nb/.plugins/tags.nb-plugin".source = ./tags.nb-plugin;
      };

      packages = with pkgs; [
        csvlens
        nb
        pandoc
        readability-cli
        ripgrep
        socat
        tig
      ];
    };

    nushell.extraScripts = [
      {
        includes = ["start-process"];
        name = "note";

        text =
          (builtins.readFile ./note.nu)
          + "\n"
          + ''
            def zk-graph-source [] {
              "${zk-graph}"
            }
          '';
      }

      {
        includes = ["note"];
        source = ./pens.nu;
      }
    ];

    programs.zk = {
      enable = true;

      settings = {
        alias = {
          last = "zk edit --limit 1 --sort modified- \"$@\"";
          ls = "zk list \"$@\"";
          random = "zk edit --limit 1 --sort random";
        };

        format.markdown.link-format = "[[{{filename}}]]";

        group.journal = {
          note = {
            filename = "{{format-date now}}";
            template = "journal.md";
          };

          paths = [journalDirectory];
        };

        notebook.dir = "~/.nb/home";
        note.template = "default.md";
        tool.fzf-preview = "bat --plain --color always {-1}";
      };
    };

    xdg.configFile = let
      templatesDirectory = "zk/templates";
    in {
      "${templatesDirectory}/default.md" = {
        force = true;

        text = ''
          ---
          tags:
            - inbox
          ---

          # {{title}}
        '';
      };

      "${templatesDirectory}/journal.md" = {
        force = true;

        text = ''
          ---
          tags:
            - journal
          ---

          # {{format-date now "%Y %B %d (%A)"}}
        '';
      };
    };
  };

  imports = [
    ../bat
    ../editor
    ../editor/markdown
    ../fzf
    ../shell
    ../version-control
    ../web/w3m
  ];

  options.nb.remotes = let
    inherit (lib) mkOption types;
    inherit (types) listOf str;
  in
    mkOption {
      default = config.user.nbRemotes;
      type = listOf str;
    };
}
