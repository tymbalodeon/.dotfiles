{
  config,
  hostName,
  lib,
  pkgs,
  ...
}: let
  aercConfigBase = "${config.xdg.configHome}/aerc";
  gmailFolderMapPath = "${aercConfigBase}/gmail-folders";
in {
  accounts.email = {
    accounts = let
      emailAccounts =
        (import ./accounts.nix {
          inherit
            config
            gmailFolderMapPath
            hostName
            lib
            pkgs
            ;
        }).accounts;
    in
      builtins.listToAttrs (
        lib.imap0
        (index: account: let
          address = account.address;
        in {
          name = account.address;

          value =
            lib.recursiveUpdate
            {
              aerc = {
                enable = true;

                extraAccounts = let
                  folders = "Inbox,Drafts,Sent,Trash,Spam,Archive";
                in
                  {
                    cache-headers = true;
                    check-mail = "1m";
                    check-mail-timeout = "2m";
                    copy-to = "Sent";
                    folders = folders;
                    folders-sort = folders;
                    from = "${account.realName} <${address}>";
                    multi-file-strategy = "act-all";
                    query-map = "~/.config/aerc/map.conf";
                    source = "notmuch://~/Mail/";
                  }
                  // account.aerc.extraAccounts;
              };

              enable = true;

              flavor =
                if lib.strings.hasSuffix "gmail.com" address
                then "gmail.com"
                else "plain";

              mbsync = {
                create = "both";
                enable = true;
                expunge = "both";
                remove = "both";
              };

              msmtp.enable = true;
              notmuch.enable = true;
              primary = index == 0;
              userName = address;
            }
            account;
        })
        emailAccounts
      );

    maildirBasePath = "Mail";
  };

  home = {
    file = {
      "${gmailFolderMapPath}" = {
        force = true;

        text = ''
          Drafts = [Gmail]/Drafts
          Sent = [Gmail]/Sent Mail
          Spam = [Gmail]/Spam
          Trash = [Gmail]/Trash
        '';
      };

      "${aercConfigBase}/map.conf" = {
        force = true;

        text = ''
          Archive=tag:archive
          Drafts=tag:draft
          Inbox=tag:inbox
          Sent=tag:sent
          Spam=tag:spam
          Trash=tag:trash
        '';
      };
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

  programs = {
    aerc = {
      enable = true;

      extraConfig = {
        filters = {
          "text/html" = "! w3m -I UTF-8 -T text/html";
          "text/plain" = "fold --width 80 | colorize";
        };

        general.unsafe-accounts-conf = true;
      };
    };

    mbsync.enable = true;
    msmtp.enable = true;

    notmuch = {
      enable = true;
      hooks.preNew = "mbsync --all";
    };
  };

  services.protonmail-bridge.enable = true;
}
