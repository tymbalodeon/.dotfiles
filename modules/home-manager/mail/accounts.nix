{
  config,
  gmailFolderMapPath,
  hostName,
  lib,
  pkgs,
  ...
}: let
  username = "benjamin.j.rosen";
  realName = config.user.name;
  escapeAddress = address: lib.replaceString "@" "%40" address;
in {
  accounts = [
    (let
      address = "${username}@gmail.com";
    in {
      inherit address realName;

      aerc.extraAccounts = let
        addressEscaped = escapeAddress address;
        getPassword = "${lib.getExe pkgs.nushell} ${./get-password.nu} ${address}";
      in {
        folder-map = gmailFolderMapPath;
        outgoing-cred-cmd = getPassword;
        outgoing = "smtps+plain://${addressEscaped}@smtp.gmail.com:465";
        source-cred-cmd = getPassword;
        source = "imaps://${addressEscaped}@imap.gmail.com:993";
      };
    })

    (let
      address = "${username}@pm.me";
    in {
      inherit address realName;

      aerc.extraAccounts = let
        addressEscaped = escapeAddress address;
        getPassword = "${lib.getExe pkgs.nushell} ${./get-password.nu} ${address} ${hostName}";
        host = "127.0.0.1";
      in {
        aliases = "${realName} <*@gmail.com>,${realName} <*@pm.me>,${realName} <*@proton.me>";
        outgoing-cred-cmd = getPassword;
        outgoing = "smtp+insecure://${addressEscaped}@${host}:1025";
        source-cred-cmd = getPassword;
        source = "imap+insecure://${addressEscaped}@${host}:1143";
      };
    })
  ];
}
