{
  imports = [../nushell];
  nushell.extraScripts = [{source = ./mail.nu;}];

  programs.neomutt = {
    enable = true;
    vimKeys = true;
  };
}
