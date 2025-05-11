{
  programs.bash = {
    enable = true;
    historyControl = ["erasedups"];
    historyIgnore = ["cd" "exit" "ls"];
    initExtra = builtins.readFile ./.bashrc;

    # TODO: store these with nushell aliases in one place
    shellAliases = {
      l = "eza --long";
      la = "eza --all --long";
      ls = "eza --oneline";
      lsa = "eza --all --oneline";
      todos = "nb todos open";
      treei = "eza --level 2 --tree";
      tree = "eza --git-ignore --level 2 --tree";
      treea = "eza --all --level 2 --tree";
    };
  };
}
