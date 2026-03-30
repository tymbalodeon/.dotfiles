{pkgs, ...}: {
  imports = [
    ../fzf
    ../nushell
    ../sqlite
    ../storage
  ];

  nushell.extraScripts = [./task.nu];

  programs.taskwarrior = {
    colorTheme = "dark-16";
    enable = true;
    package = pkgs.taskwarrior3;
  };
}
