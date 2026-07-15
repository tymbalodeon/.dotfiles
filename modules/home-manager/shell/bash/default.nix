{
  imports = [../../eza];

  programs = {
    bash = {
      enable = true;
      historyControl = ["erasedups"];
      historyIgnore = ["cd" "exit" "ls"];

      initExtra = ''
        PS1="\[\e[1m\e[1;36m\w\e[0m\]\n$ "
        PS2="\[\e[1m\e[1;32m>\e[0m\] "
      '';

      shellAliases = {
        l = "eza --long";
        la = "eza --all --long";
        ls = "eza --oneline";
        lsa = "eza --all --oneline";
        ssh = ". '${./ssh.sh}'";
      };
    };

    kitty.shellIntegration.mode = "no-cursor no-rc";

    readline = {
      enable = true;

      variables = {
        show-mode-in-prompt = true;
        vi-cmd-mode-string = ''\1\e[2 q\2'';
        vi-ins-mode-string = ''\1\e[6 q\2'';
      };
    };
  };
}
