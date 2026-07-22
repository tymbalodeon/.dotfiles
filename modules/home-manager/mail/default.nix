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
      emailAccounts =
        (import ./accounts.nix {
          inherit config gmailFolderMapPath hostName lib pkgs;
        }).accounts;
    in
      builtins.listToAttrs (
        lib.imap0
        (index: account: {
          name = account.address;

          value = rec {
            inherit (account) address realName;

            aerc = {
              enable = true;

              extraAccounts = let
                folders = "INBOX,Drafts,Sent,Trash,Spam,Archive";
              in
                {
                  cache-headers = true;
                  check-mail = "1m";
                  copy-to = "Sent";
                  folders = folders;
                  folders-sort = folders;
                  from = "${realName} <${address}>";
                }
                // account.aerc.extraAccounts;
            };

            enable = true;

            flavor =
              if lib.strings.hasSuffix "gmail.com" address
              then "gmail.com"
              else "plain";

            primary = index == 0;
          };
        })
        emailAccounts
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
