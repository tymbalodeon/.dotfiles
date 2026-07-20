{
  config,
  hostName,
  lib,
  pkgs,
  ...
}: let
  addresses = defaultUser.email.addresses;
  defaultUser = import ../../users;

  filterAddresses = provider:
    builtins.filter
    (address: lib.strings.hasSuffix provider address)
    addresses;

  getConfigs = addresses:
    builtins.toJSON (
      map (
        address: {
          inherit address;

          password-path = getPasswordPath address;
          username = getUsername address;
        }
      )
      addresses
    );

  getPasswordPath = address:
    config.sops.secrets."mail/${address}/password".path;

  getUsername = address:
    lib.lists.elemAt
    (lib.strings.splitString "@" address)
    0;

  gmailAddresses = filterAddresses "gmail.com";
  gmailConfigs = getConfigs gmailAddresses;
  gmailFolderMapPath = "${config.xdg.configHome}/aerc/gmail-folders";
  protonAddresses = builtins.toJSON (filterAddresses "pm.me");
in {
  accounts.email = {
    accounts = let
      defaultUser = import ../../users;
    in
      builtins.listToAttrs (
        lib.imap0
        (index: address: {
          name = address;

          value = {
            inherit address;

            flavor =
              if lib.strings.hasSuffix "gmail.com" address
              then "gmail.com"
              else "plain";

            primary = index == 0;
            realName = defaultUser.name;
          };
        })
        defaultUser.email.addresses
      );

    maildirBasePath = "Mail";
  };

  home = {
    activation.mail = let
      script =
        pkgs.writeScript "activate-mail"
        #nushell
        (
          ''
            def real-name [] {
              "${defaultUser.name}"
            }

            def gmail-accounts [] {
              '${gmailConfigs}'
              | from json
            }

            def protonmail-addresses [] {
              '${protonAddresses}'
              | from json
            }

            def folder-map-path [] {
              "${gmailFolderMapPath}"
            }

            def nushell-path [] {
              "${lib.getExe pkgs.nushell}"
            }

            def cred-cmd [] {
              "${./get-password.nu}"
            }

            def hostname [] {
              "${hostName}"
            }
          ''
          + builtins.readFile ./home-activation.nu
        );
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        run ${lib.getExe pkgs.nushell} "${script}"
      '';

    file."${gmailFolderMapPath}" = {
      force = true;

      text = ''
        All Mail = [Gmail]/All Mail
        Drafts = [Gmail]/Drafts
        Sent = [Gmail]/Sent Mail
        Spam = [Gmail]/Spam
        Starred = [Gmail]/Starred
        Trash = [Gmail]/Trash
      '';
    };

    packages = with pkgs; [
      protonmail-bridge-gui
    ];
  };

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
      filters."text/plain" = "fold --width 80 | colorize";
      general.unsafe-accounts-conf = true;
    };
  };

  services.protonmail-bridge.enable = true;

  sops.secrets =
    builtins.foldl' (a: b: a // b) {}
    (
      map
      (address: {"mail/${address}/password" = {};})
      gmailAddresses
    );
}
