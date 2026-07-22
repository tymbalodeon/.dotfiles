{
  config,
  gmailFolderMapPath,
  hostName,
  lib,
  pkgs,
  ...
}: let
  escapeAddress = address: lib.replaceString "@" "%40" address;
  nu = lib.getExe pkgs.nushell;
  realName = config.user.name;
  username = "benjamin.j.rosen";
in {
  accounts = [
    (let
      address = "${username}@gmail.com";

      imap = {
        host = "imap.gmail.com";
        port = 993;
      };

      passwordCommand = "${nu} ${./get-password.nu} ${address}";

      smtp = {
        host = "smtp.gmail.com";
        port = 465;
      };
    in {
      inherit
        address
        imap
        passwordCommand
        realName
        smtp
        ;

      aerc.extraAccounts = let
        addressEscaped = escapeAddress address;
      in {
        check-mail-cmd = "mbsync ${address} && notmuch new --no-hooks ${address}";
        folder-map = gmailFolderMapPath;
        outgoing-cred-cmd = passwordCommand;
        outgoing = "smtps+plain://${addressEscaped}@${smtp.host}:${toString smtp.port}";
        source-cred-cmd = passwordCommand;
      };

      mbsync.patterns = [
        "Archive"
        "[Gmail]/Drafts"
        "[Gmail]/Sent Mail"
        "[Gmail]/Spam"
        "[Gmail]/Trash"
        "INBOX"
      ];
    })

    (let
      address = "${username}@pm.me";
      host = "127.0.0.1";
      passwordCommand = "${nu} ${./get-password.nu} ${address} ${hostName}";
      smtp_port = 1025;
    in {
      inherit address passwordCommand realName;

      aerc.extraAccounts = let
        addressEscaped = escapeAddress address;
      in {
        aliases = "${realName} <*@gmail.com>,${realName} <*@pm.me>,${realName} <*@proton.me>";

        # FIXME: mbsync with protonmail always fails, but still gets the mail
        # For now, using || so that running aerc doesn't fail, but this should
        # be corrected!
        check-mail-cmd = "mbsync ${address} || notmuch new --no-hooks ${address}";

        outgoing-cred-cmd = passwordCommand;
        outgoing = "smtp+plain://${addressEscaped}@${host}:${toString smtp_port}";
        query-map = "~/.config/aerc/map.conf";
        source-cred-cmd = passwordCommand;
      };

      aliases = [
        "${username}@protonmail.com"
        "${username}@proton.me"
      ];

      imap = {
        inherit host;

        port = 1143;
      };

      mbsync = {
        extraConfig.account.TLSType = "NONE";

        patterns = [
          "Archive"
          "INBOX"
          "Drafts"
          "Sent"
          "Spam"
          "Trash"
        ];
      };

      smtp = {
        inherit host;

        port = smtp_port;
      };
    })
  ];
}
