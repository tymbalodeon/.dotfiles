{pkgs, ...}: let
  journalDirectory = "journal";
in {
  imports = [
    ../nb
    ../nushell
  ];

  nushell.extraScripts = [
    (pkgs.writeText "zk.nu" ''
      use ${../nb/get-nb-dir.nu} get-nb-dir

      def --wrapped run-zk [...args: string] {
        SHELL=$"(^which bash)" ^zk ...$args
      }

      def sync-zk-directory [] {
        if (
          git -C (get-nb-dir) status --short
          | is-not-empty
        ) {
          nb sync
        }
      }

      def --wrapped zk [...args: string] {
        if ($args | first) in [edit new] {
          run-zk ...$args
          sync-zk-directory
        } else {
          run-zk ...$args
        }
      }

      def note-title [title: list<string>] {
        $title
        | str join " "
      }

      def note [title: list<string>] {
        (
          zk list
            --format "{{path}}"
            --limit 1
            --match $"title: (note-title $title)"
            --no-pager
            err> /dev/null
          | str trim
        )
      }

      def "zk edit" [...search_terms: string] {
        if ($search_terms | is-empty) {
          run-zk edit --interactive
        } else {
          let note = (note $search_terms)

          if ($note | is-empty) {
            run-zk edit --match ...$search_terms --interactive
          } else {
            run-zk edit $note
          }
        }
      }

      def "zk journal" [] {
        let working_dir = (get-nb-dir)

        mkdir ($working_dir | path join "${journalDirectory}")

        (
          run-zk new
            --no-input "$ZK_NOTEBOOK_DIR/journal"
            --working-dir $working_dir
        )

        sync-zk-directory
      }

      def "zk links" [...title: string] {
        zk list --interactive --link-to (note $title) err> /dev/null
      }

      def "zk new" [...title: string] {
        if ($title | is-not-empty) {
          run-zk new --title (note-title $title)
        } else {
          run-zk new
        }

        sync-zk-directory
      }

    '')
  ];

  programs.zk = {
    enable = true;

    settings = {
      alias = {
        last = "zk edit --limit 1 --sort modified- \"$@\"";
        ls = "zk list \"$@\"";
        random = "zk edit --limit 1 --sort random";
      };

      group.journal = {
        note = {
          filename = "{{format-date now}}";
          tempalte = "journal.md";
        };

        paths = [journalDirectory];
      };

      notebook.dir = "~/.nb/home";
      tool.fzf-preview = "bat --plain --color always {-1}";
    };
  };

  xdg.configFile.".zk/templates/journal.md".text = "# {{format-date now \"long\"}}";
}
