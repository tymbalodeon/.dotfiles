{
  imports = [
    ../fzf
    ../nushell
  ];

  nushell.extraScripts = [./storage.nu];
  programs.rclone.enable = true;
}
