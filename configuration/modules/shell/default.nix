{
  imports = [
    ../bash
    ../eza
    ../nushell
  ];

  programs = let
    shellAliases = {
      tree = "eza --git-ignore --level 2 --tree";
      treea = "eza --all --level 2 --tree";
      treei = "eza --level 2 --tree";
    };
  in {
    bash.shellAliases = shellAliases;
    nushell.shellAliases = shellAliases;
  };
}
