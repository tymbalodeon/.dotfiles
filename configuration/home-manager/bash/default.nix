{
  imports = [../eza];

  programs.bash = {
    enable = true;
    historyControl = ["erasedups"];
    historyIgnore = ["cd" "exit" "ls"];

    # TODO: set vi mode cursors
    initExtra = ''
      set -o vi

      PS1="\[\e[1m\e[1;32m\w\n$\e[0m\] "
      PS2="\[\e[37m>\e[0m\] "
    '';

    shellAliases = {
      l = "eza --long";
      la = "eza --all --long";
      ls = "eza --oneline";
      lsa = "eza --all --oneline";
      ssh = ". '${./ssh.sh}'";
    };
  };
}
