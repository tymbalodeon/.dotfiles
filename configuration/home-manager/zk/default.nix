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

      def --wrapped _zk [...args: string] {
        SHELL=$"(^which bash)" ^zk ...$args
      }

      def --wrapped zk [...args: string] {
        mut is_main_zk = false

        let args = if not (".zk" | path exists) {
          $is_main_zk = true

          $args
          | append [--working-dir (get-nb-dir)]
        } else {
          $args
        }

        let subcommand = ($args | first)

        if $is_main_zk and ($args | first) in [edit new] {
          _zk ...$args

          if (
            git -C (get-nb-dir) status --short
            | is-not-empty
          ) {
              nb sync
          }
        } else {
          _zk ...$args
        }
      }

      def "zk journal" [] {
        let working_dir = (get-nb-dir)

        mkdir ($working_dir | path join "${journalDirectory}")
        _zk --working-dir (get-nb-dir) journal
      }
    '')
  ];

  programs.zk = {
    enable = true;

    settings = {
      alias = {
        journal = "zk new --no-input \"$ZK_NOTEBOOK_DIR/journal\"";
        last = "zk edit --limit 1 --sort modified- $@";
        random = "zk edit --limit 1 --sort random";
      };

      group.journal = {
        note = {
          filename = "{{format-date now}}";
          tempalte = "journal.md";
        };

        paths = [journalDirectory];
      };
    };
  };

  xdg.configFile.".zk/templates/journal.md".text = "# {{format-date now \"long\"}}";
}
