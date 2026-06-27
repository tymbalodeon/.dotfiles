{config, ...}: let
  neomuttrcPath = "neomutt/neomuttrc";
in {
  imports = [
    ../secrets
    ../shell/nushell
  ];

  nushell.extraScripts = [{source = ./mail.nu;}];

  programs.neomutt = {
    enable = true;
    vimKeys = true;
  };

  sops.secrets.${neomuttrcPath} = {};

  xdg.configFile.${neomuttrcPath}.source =
    config.sops.secrets.${neomuttrcPath}.path;
}
