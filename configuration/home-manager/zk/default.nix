{
  imports = [../nushell];
  programs.zk.enable = true;
  nushell.extraScripts = [./zk.nu];
}
