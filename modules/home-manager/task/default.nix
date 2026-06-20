{pkgs, ...}: {
  imports = [../nushell];

  nushell.extraScripts = [
    {
      name = "task";
      text = builtins.readFile ./task.nu;
    }
  ];

  programs.taskwarrior = {
    colorTheme = "dark-16";
    enable = true;
    package = pkgs.taskwarrior3;
  };
}
