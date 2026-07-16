{
  config,
  lib,
  pkgs,
  ...
}: let
  accounts = builtins.toJSON (
    map (
      account: let
        username = getUsername account.value.address;
      in {
        inherit username;

        password-path = config.sops.secrets."gmail/${username}/password".path;
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
  # FIXME
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

  nushell.extraScripts = [{source = ./mail.nu;}];

  programs = {
    aerc = {
      enable = true;
      extraConfig.general.unsafe-accounts-conf = true;
    };

    neomutt = {
      extraConfig = ''
        color attachment color5 default
        color body color2 default [\-\.+_a-zA-Z0-9]+@[\-\.a-zA-Z0-9]+
        color body color2 default (https?|ftp)://[\-\.,/%~_:?&=\#a-zA-Z0-9]+
        color body color4 default (^|[[:space:]])/[^[:space:]]+/([[:space:]]|$)
        color body color4 default (^|[[:space:]])\\*[^[:space:]]+\\*([[:space:]]|$)
        color body color4 default (^|[[:space:]])_[^[:space:]]+_([[:space:]]|$)
        color error color1 default
        color hdrdefault color13 default
        color header color13 default "^From:"
        color header color13 default "^Subject:"
        color index_author color4 default ".*"
        color index color13 default ~T
        color index color1 default ~D
        color index color1 default ~F
        color index color2 default ~N
        color index_date color5 default ".*"
        color index_flags color3 default ".*"
        color index_subject color6 default ".*"
        color indicator default color8
        color normal default default
        color quoted1 color7 default
        color quoted2 color8 default
        color quoted3 color0 default
        color quoted4 color0 default
        color quoted5 color0 default
        color quoted color15 default
        color search color4 default
        color sidebar_flagged color1 default
        color sidebar_new color10 default
        color signature color8 default
        color status color15 default
        color tilde color15 default
        color tree color15 default

        set account_command = "${./account-command.nu}"
        set virtual_spoolfile
      '';

      sidebar.enable = true;
      sort = "reverse-date";
      vimKeys = true;
    };
  };

  services.protonmail-bridge.enable = true;

  sops.secrets =
    builtins.foldl' (a: b: a // b) {}
    (
      map
      (account: {"gmail/${getUsername account.value.address}/password" = {};})
      gmailAccounts
    );
}
