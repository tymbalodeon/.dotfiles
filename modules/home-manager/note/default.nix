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
      # TODO: handle $VERBOSE and $DRY_RUN
      # TODO: is it possible to git pull the remote notes here?
      activation.nb = let
        git = lib.getExe pkgs.git;
      in
        lib.hm.dag.entryAfter ["writeBoundary"]
        ''
          remotes=(${lib.concatStringsSep " " cfg.remotes})
          nbHome="$HOME/.nb"

          mkdir --parents $nbHome

          notebooks=$(ls $nbHome)
          index=0

          for remote in "''${remotes[@]}"; do
            if [[ "$index" = 0 ]]; then
              name=home
            else
              url=''${remote/git@/}
              url=''${url/.com/}

              read domain user name < <(
                echo $url |
                ${lib.getExe pkgs.gawk} --field-separator [/:] '{print $1, $(NF-1), $NF}'
              )

              name=''${name/.git/}
              name=''${domain}-''${user}-''${name}
            fi

            if [[ ! " ''${notebooks[*]} " =~ [[:space:]]$name[[:space:]] ]]; then
              directory="$nbHome/$name"

              mkdir --parents $directory
              cd $directory

              ${git} init
              ${git} remote add origin $remote

              # TODO: add an option to specify the branch if it's not "trunk"
              ${git} branch -m trunk
            fi

            index+=1
          done
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

      {source = ./pens.nu;}
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

        lsp.diagnostics.wiki-title = "hint";
        notebook.dir = "~/.nb/home";
        tool.fzf-preview = "bat --plain --color always {-1}";
      };
    };

    xdg.configFile."zk/templates/journal.md" = {
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

  imports = [
    ../shell/bash
    ../bat
    ../fzf
    ../git
    ../helix
    ../helix/markdown
    ../shell/nushell
    ../w3m
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
