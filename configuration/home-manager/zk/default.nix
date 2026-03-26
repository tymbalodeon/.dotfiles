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

      def "zk journal" [] {
        let working_dir = (get-nb-dir)

        mkdir ($working_dir | path join "${journalDirectory}")
        run-zk --working-dir (get-nb-dir) journal
        sync-zk-directory
      }
    '')
  ];

  programs.zk = {
    enable = true;

    settings = {
      alias = {
        edit = "zk edit --interactive \"$@\"";
        find = "zk list --match \"$@\"";
        journal = "zk new --no-input \"$ZK_NOTEBOOK_DIR/journal\"";
        last = "zk edit --limit 1 --sort modified- \"$@\"";
        links = "zk list --interactive --link-to \"$@\"";
        ls = "zk list \"$@\"";
        new = "zk new --title \"$*\"";
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
    };
  };

  xdg.configFile.".zk/templates/journal.md".text = "# {{format-date now \"long\"}}";
}
