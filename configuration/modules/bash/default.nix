{
  # TODO: need for ssh below
  pkgs,
  ...
}: {
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

        # TODO: make bash version of this (see ./ssh.sh)
        ssh = let
          defaultUser = import ../users/default-user.nix;
          filename = builtins.toString ./ssh.sh;

          homeDirectory = builtins.toString (
            if pkgs.stdenv.isLinux
            then defaultUser.homeDirectoryLinux
            else defaultUser.homeDirectoryDarwin
          );
        in ". '${homeDirectory}/${filename}'";
      }
      // (import ../aliases.nix);
  };
}
