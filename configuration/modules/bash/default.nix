{pkgs, ...}: {
  programs.bash = {
    enable = true;
    historyControl = ["erasedups"];
    historyIgnore = ["cd" "exit" "ls"];
    # TODO: conditionally include darwin
    initExtra = builtins.readFile ./.bashrc;
    package = pkgs.bashInteractive;

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
