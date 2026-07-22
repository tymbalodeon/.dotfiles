{
  config,
  hostName,
  lib,
  pkgs,
  ...
}: let
  gmailFolderMapPath = "${config.xdg.configHome}/aerc/gmail-folders";
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

            aerc = {
              enable = true;

              extraAccounts = let
                addressEscaped = lib.replaceString "@" "%40" address;
                folders = "INBOX,Drafts,Sent,Trash,Spam,Archive";
                realName = defaultUser.name;
              in
                {
                  cache-headers = true;
                  check-mail = "1m";
                  copy-to = "Sent";
                  folders = folders;
                  folders-sort = folders;
                  from = "${realName} <${address}>";
                }
                // (
                  if (lib.strings.hasSuffix "gmail.com" address)
                  then let
                    getPassword = "${lib.getExe pkgs.nushell} ${./get-password.nu} ${address}";
                  in {
                    folder-map = gmailFolderMapPath;
                    outgoing-cred-cmd = getPassword;
                    outgoing = "smtps+plain://${addressEscaped}@smtp.gmail.com:465";
                    source-cred-cmd = getPassword;
                    source = "imaps://${addressEscaped}@imap.gmail.com:993";
                  }
                  else if (lib.strings.hasSuffix "pm.me" address)
                  then let
                    getPassword = "${lib.getExe pkgs.nushell} ${./get-password.nu} ${address} ${hostName}";
                  in {
                    aliases = "${realName} <*@gmail.com>,${realName} <*@pm.me>,${realName} <*@proton.me>";
                    outgoing-cred-cmd = getPassword;
                    outgoing = "smtp+insecure://${addressEscaped}@127.0.0.1:1025";
                    source-cred-cmd = getPassword;
                    source = "imap+insecure://${addressEscaped}@127.0.0.1:1143";
                  }
                  else {}
                );
            };

            enable = true;

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

  imports = [../shell/nushell];

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
        "text/html" = "! w3m -I UTF-8 -T text/html";
        "text/plain" = "fold --width 80 | colorize";
      };

      general.unsafe-accounts-conf = true;
    };
  };

  services.protonmail-bridge.enable = true;
}
