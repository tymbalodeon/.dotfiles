{
  programs.bash = {
    enable = true;
    historyControl = ["erasedups"];
    historyIgnore = ["cd" "exit" "ls"];
    initExtra = builtins.readFile ./.bashrc;

    shellAliases =
      {
        l = "eza --long";
        la = "eza --all --long";
        ls = "eza --oneline";
        lsa = "eza --all --oneline";

        # FIXME
        # ssh = let
        #   defaultUser = import ../users/shared.nix;
        #   filename = builtins.toString ./ssh.sh;

        #   homeDirectory = builtins.toString (
        #     if pkgs.stdenv.isLinux
        #     then defaultUser.homeDirectoryLinux
        #     else defaultUser.homeDirectoryDarwin
        #   );
        # in ". '${homeDirectory}/${filename}'";
      }
      // (import ../aliases.nix);
  };
}
