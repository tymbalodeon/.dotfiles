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

      # Cd to the `zk` home  directory
      def --env "zk cd" [] {
        cd (get-nb-dir)
      }

      # Edit notes
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

      # Create or edit the current day's journal entry
      def "zk journal" [] {
        let working_dir = (get-nb-dir)
        let journal = ($working_dir | path join "${journalDirectory}")

        mkdir $journal
        run-zk new $journal --no-input --working-dir $working_dir
        sync-zk-directory
      }

      # Interactively select a journal entry to edit
      def "zk journal edit" [] {
        ^zk edit --interactive --tag journal
      }

      # List journal entries
      def "zk journal list" [] {
        zk list --tag journal
      }

      alias "zk journal ls" = zk journal list

      # Show links for notes
      def "zk links" [...title: string] {
        let note = (note $title)

        let note = if ($note | is-empty) {
          $title
          | first
        } else {
          $note
        }

        ^zk edit --interactive --link-to $note err> /dev/null
      }

      # Add new note
      def "zk new" [...title: string] {
        if ($title | is-not-empty) {
          run-zk new --title (note-title $title)
        } else {
          run-zk new
        }

        sync-zk-directory
      }

      # Remove notes
      def "zk remove" [note?: string] {
        let notes = if ($note | is-not-empty) {
          zk list --format "{{abs-path}}" --no-pager --match $note --quiet
          | lines
        } else {
          try {
            zk list --format "{{abs-path}}" --interactive --quiet
          } catch {
            return
          }
        }

        if ($notes | is-empty) {
          return
        }

        for note in $notes {
          if (input $"Are you sure you want to remove ($note)? [y/N]: ") in [Y y] {
            rm $note
          }
        }

        sync-zk-directory
      }

      alias "zk rm" = zk remove
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

  xdg.configFile.".zk/templates/journal.md".text = ''
    ---
    tags: [journal]
    ---

    # {{format-date now \"long\"}}'';
}
