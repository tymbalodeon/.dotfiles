{
  programs.bash = {
    enable = true;
    historyControl = ["erasedups"];
    historyIgnore = ["cd" "exit" "ls"];
    initExtra = builtins.readFile ./.bashrc;

    # TODO: store these with nushell aliases in one place
    shellAliases = {
      l = "ls -l";
      la = "ls -a -l";
      lsa = "ls -a";
      todos = "nb todos open";
      treei = "eza --tree --level=2";
      tree = "treei --git-ignore";
      treea = "treei --all";
    };
  };
}
