{
  config,
  lib,
  pkgs,
  ...
}: let
  nicknamePath = "irc/nickname";
  psaswordPath = "irc/password";
in {
  home = {
    activation.irc = let
      script =
        pkgs.writeScript "activate-irc"
        # nushell
        (
          ''
            def senpai-config-path [] {
              "${config.xdg.configHome}"
              | path join senpai/senpai.scfg
            }

            def nickname [] {
              try {
                open ${config.sops.secrets.${nicknamePath}.path}
              }
            }

            def password [] {
              try {
                open ${config.sops.secrets.${psaswordPath}.path}
              }
            }
          ''
          + builtins.readFile ./home-activation.nu
        );
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        run ${lib.getExe pkgs.nushell} "${script}"
      '';

    packages = [pkgs.senpai];
  };

  nushell.extraScripts = [{source = ./irc.nu;}];

  imports = [
    ../shell/nushell
    ../secrets
  ];

  sops.secrets = {
    ${nicknamePath} = {};
    ${psaswordPath} = {};
  };
}
