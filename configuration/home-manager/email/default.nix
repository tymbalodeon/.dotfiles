{
  imports = [../nushell];
  nushell.extraScripts = [./email.nu];

  programs.neomutt = {
    enable = true;
    vimKeys = true;
  };
}
