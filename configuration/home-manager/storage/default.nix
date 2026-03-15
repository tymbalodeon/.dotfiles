{
  imports = [../nushell];
  nushell.extraScripts = [./storage.nu];
  programs.rclone.enable = true;
}
