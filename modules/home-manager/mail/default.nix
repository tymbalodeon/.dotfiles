{
  config,
  lib,
  pkgs,
  ...
}: let
  accounts = builtins.toJSON (
    map (
      account: let
        address = account.value.address;
        username = getUsername account.value.address;
      in {
        inherit username;

        password-path = config.sops.secrets."mail/${address}/password".path;
        real-name = account.value.realName;
      }
    )
    gmailAccounts
  );

  getUsername = address:
    lib.lists.elemAt
    (lib.strings.splitString "@" address)
    0;

  gmailAccounts = (
    builtins.filter
    (account: account.value.flavor == "gmail.com")
    (lib.attrsToList config.accounts.email.accounts)
  );
in {
  accounts.email = {
    accounts = let
      user = import ../../users;
    in {
      ${user.email} = {
        address = user.email;
        flavor = "gmail.com";
        primary = true;
        realName = user.name;
      };
    };

    maildirBasePath = "Mail";
  };

  home.activation.mail = let
    script =
      pkgs.writeScript "activate-mail"
      #nushell
      (
        ''
          def gmail-accounts [] {
            '${accounts}'
            | from json
          }
        ''
        + builtins.readFile ./home-activation.nu
      );
  in
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${lib.getExe pkgs.nushell} "${script}"
    '';

  imports = [
    ../secrets
    ../shell/nushell
  ];

  nushell.extraAliases = let
    mailProgram = "aerc";
  in {
    email = mailProgram;
    mail = mailProgram;
  };

  programs.aerc = {
    enable = true;

    extraConfig = {
      filters = {
        "text/plain" = "fold --width 80 | colorize";
      };

      general.unsafe-accounts-conf = true;
    };
  };

  services.protonmail-bridge.enable = true;

  sops.secrets =
    builtins.foldl' (a: b: a // b) {}
    (
      map
      (account: {"mail/${account.value.address}/password" = {};})
      gmailAccounts
    );
}
