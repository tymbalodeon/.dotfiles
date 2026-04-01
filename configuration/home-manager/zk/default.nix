let
  journalDirectory = "journal";
in {
  imports = [
    ../nb
    ../nushell
  ];

  nushell.extraScripts = [./zk.nu];

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
