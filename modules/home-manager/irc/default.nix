{
  config,
  lib,
  pkgs,
  ...
}: let
  nickname = ''
    def nickname [] {
      try {
        open ${config.sops.secrets.${nicknamePath}.path}
      }
    }
  '';

  nicknamePath = "irc/nickname";
  passwordPath = "irc/password";
in {
  home = {
    activation.irc = let
      script =
        pkgs.writeScript "activate-irc"
        # nushell
        (
          ''
            def config-path [] {
              "${config.xdg.configHome}"
              | path join senpai/senpai.scfg
            }

            def password [] {
              try {
                open ${config.sops.secrets.${passwordPath}.path}
              }
            }
          ''
          + "\n"
          + nickname
          + "\n"
          + builtins.readFile ./home-activation.nu
        );
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        run ${lib.getExe pkgs.nushell} "${script}"
      '';

    packages = [pkgs.senpai];
  };

  nushell.extraScripts = [
    {
      name = "irc";
      text = nickname + "\n" + (builtins.readFile ./irc.nu);
    }
  ];

  imports = [
    ../shell/nushell
    ../secrets
  ];

  sops.secrets = {
    ${nicknamePath} = {};
    ${passwordPath} = {};
  };
}
