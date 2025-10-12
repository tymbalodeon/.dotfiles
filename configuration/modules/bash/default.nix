{
  imports = [../eza];

  programs.bash = {
    enable = true;
    historyControl = ["erasedups"];
    historyIgnore = ["cd" "exit" "ls"];
    initExtra = builtins.readFile ./.bashrc;

    shellAliases = {
      l = "eza --long";
      la = "eza --all --long";
      ls = "eza --oneline";
      lsa = "eza --all --oneline";
      ssh = ". '${./ssh.sh}'";
    };
  };
}
