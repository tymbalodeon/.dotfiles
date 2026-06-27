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

  # FIXME: pull out secrets only and combine with the rest stored here
  xdg.configFile.${neomuttrcPath}.source =
    config.sops.secrets.${neomuttrcPath}.path;
}
