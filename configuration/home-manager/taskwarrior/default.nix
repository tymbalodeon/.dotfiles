{pkgs, ...}: {
  imports = [
    ../nushell
    ../sqlite
    ../storage
  ];

  nushell.extraScripts = [
    ./sync.nu
  ];

  programs.taskwarrior = {
    colorTheme = "dark-16";
    enable = true;
    package = pkgs.taskwarrior3;
  };
}
