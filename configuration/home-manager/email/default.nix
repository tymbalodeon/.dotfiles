{
  imports = [../nushell];
  nushell.extraScripts = [{source = ./email.nu;}];

  programs.neomutt = {
    enable = true;
    vimKeys = true;
  };
}
