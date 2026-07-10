{
  config,
  lib,
  pkgs,
  ...
}: let
  ipAddressPath = "irc/ip-address";
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

            def ip-address [] {
              try {
                open ${config.sops.secrets.${ipAddressPath}.path}
              }
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
        ${lib.getExe pkgs.nushell} "${script}"
      '';

    packages = [pkgs.senpai];
  };

  imports = [../secrets];

  sops.secrets = {
    ${ipAddressPath} = {};
    ${nicknamePath} = {};
    ${psaswordPath} = {};
  };
}
