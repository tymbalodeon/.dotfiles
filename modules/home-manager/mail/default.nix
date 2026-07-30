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
                  folders = "Unread,Flagged,Inbox,Drafts,Sent,Trash,Spam,Archive";
                in
                  {
                    cache-headers = true;
                    check-mail = "10m";
                    check-mail-timeout = "2m";
                    copy-to = "Sent";
                    default = "tag:inbox";
                    folders = folders;
                    folders-sort = folders;
                    from = "${account.realName} <${address}>";
                    multi-file-strategy = "act-all";
                    query-map = "~/.config/aerc/map.conf";
                    source = "notmuch://";
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
          Flagged=tag:flagged
          Inbox=tag:inbox
          Sent=tag:sent
          Spam=tag:spam
          Trash=tag:trash
          Unread=tag:unread
        '';
      };
    };

    packages = with pkgs; [
      protonmail-bridge-gui
    ];
  };

  imports = [../shell/nushell];

  nushell.extraScripts = [
    {
      includes = ["user-config"];
      source = ./mail.nu;
    }
  ];

  programs = {
    aerc = {
      enable = true;

      extraBinds = {
        global = {
          "<C-c>" = ":prompt 'Quit?' quit<Enter>";
          "<C-n>" = ":next-tab<Enter>";
          "<C-PgDn>" = ":next-tab<Enter>";
          "<C-PgUp>" = ":prev-tab<Enter>";
          "<C-p>" = ":prev-tab<Enter>";
          "<C-q>" = ":prompt 'Quit?' quit<Enter>";
          "<C-t>" = ":term<Enter>";
          "<C-z>" = ":suspend<Enter>";
          "?" = ":help keys<Enter>";
          o = ":check-mail<Enter>";
          "\\]t" = ":next-tab<Enter>";
          "\\[t" = ":prev-tab<Enter>";
        };

        compose = {
          "$complete" = "<C-o>";
          "$ex" = "<C-x>";
          "$noinherit" = true;
          "<A-n>" = ":switch-account -n<Enter>";
          "<A-p>" = ":switch-account -p<Enter>";
          "<backtab>" = ":prev-field<Enter>";
          "<C-Down>" = ":next-field<Enter>";
          "<C-j>" = ":next-field<Enter>";
          "<C-k>" = ":prev-field<Enter>";
          "<C-Left>" = ":switch-account -p<Enter>";
          "<C-n>" = ":next-tab<Enter>";
          "<C-PgDn>" = ":next-tab<Enter>";
          "<C-PgUp>" = ":prev-tab<Enter>";
          "<C-p>" = ":prev-tab<Enter>";
          "<C-Right>" = ":switch-account -n<Enter>";
          "<C-Up>" = ":prev-field<Enter>";
          "<tab>" = ":next-field<Enter>";
        };

        "compose::editor" = {
          "$ex" = "<C-x>";
          "$noinherit" = true;
          "<C-Down>" = ":next-field<Enter>";
          "<C-j>" = ":next-field<Enter>";
          "<C-k>" = ":prev-field<Enter>";
          "<C-n>" = ":next-tab<Enter>";
          "<C-PgDn>" = ":next-tab<Enter>";
          "<C-PgUp>" = ":prev-tab<Enter>";
          "<C-p>" = ":prev-tab<Enter>";
          "<C-Up>" = ":prev-field<Enter>";
        };

        "compose::review" = {
          a = ":attach<space>";
          d = ":detach<space>";
          e = ":edit<Enter>";
          n = ":abort<Enter>";
          p = ":postpone<Enter>";
          q = ":choose -o d discard abort -o p postpone postpone<Enter>";
          s = ":sign<Enter>";
          v = ":preview<Enter>";
          x = ":encrypt<Enter>";
          y = ":send<Enter>";
        };

        messages = {
          "$" = ":term<space>";
          a = ":archive flat<Enter>";
          A = ":unmark -a<Enter>:mark -T<Enter>:archive flat<Enter>";
          b = ":bounce<space>";
          "<C-b>" = ":prev 100%<Enter>";
          c = ":cf<space>";
          C = ":compose<Enter>";
          "<C-d>" = ":next 50%<Enter>";
          "<C-Down>" = ":next-folder<Enter>";
          "<C-f>" = ":next 100%<Enter>";
          "<C-Left>" = ":collapse-folder<Enter>";
          "<C-Right>" = ":expand-folder<Enter>";
          "<C-Up>" = ":prev-folder<Enter>";
          "<C-u>" = ":prev 50%<Enter>";
          d = ":choose -o y 'Really delete this message' delete-message<Enter>";
          D = ":delete<Enter>";
          "<Down>" = ":next<Enter>";
          "<Enter>" = ":view<Enter>";
          "<Esc>" = ":clear<Enter>";
          "\\" = ":filter<space>";
          g = ":select 0<Enter>";
          G = ":select -1<Enter>";
          H = ":collapse-folder<Enter>";
          j = ":next<Enter>";
          J = ":next-folder<Enter>";
          k = ":prev<Enter>";
          K = ":prev-folder<Enter>";
          L = ":expand-folder<Enter>";
          m = ":compose<Enter>";
          n = ":next-result<Enter>";
          N = ":prev-result<Enter>";
          pa = ":patch apply <Tab>";
          pb = ":patch rebase<Enter>";
          pd = ":patch drop <Tab>";
          "<PgDn>" = ":next 100%<Enter>";
          "<PgUp>" = ":prev 100%<Enter>";
          "|" = ":pipe<space>";
          pl = ":patch list<Enter>";
          ps = ":patch switch <Tab>";
          pt = ":patch term<Enter>";
          q = ":prompt 'Quit?' quit<Enter>";
          rq = ":reply -aq<Enter>";
          Rq = ":reply -q<Enter>";
          rr = ":reply -a<Enter>";
          Rr = ":reply<Enter>";
          "/" = ":search<space>";
          "<Space>" = ":mark -t<Enter>:next<Enter>";
          s = ":split<Enter>";
          S = ":vsplit<Enter>";
          "<tab>" = ":fold -t<Enter>";
          "!" = ":term<space>";
          T = ":toggle-threads<Enter>";
          "<Up>" = ":prev<Enter>";
          v = ":mark -t<Enter>";
          V = ":mark -v<Enter>";
          za = ":fold -t<Enter>";
          zb = ":align bottom<Enter>";
          zc = ":fold<Enter>";
          zM = ":fold -a<Enter>";
          zo = ":unfold<Enter>";
          zR = ":unfold -a<Enter>";
          zt = ":align top<Enter>";
          zz = ":align center<Enter>";
        };

        "messages:folder=Drafts"."<Enter>" = ":recall<Enter>";

        terminal = {
          "$ex" = "<C-x>";
          "$noinherit" = true;
          "<C-n>" = ":next-tab<Enter>";
          "<C-PgDn>" = ":next-tab<Enter>";
          "<C-PgUp>" = ":prev-tab<Enter>";
          "<C-p>" = ":prev-tab<Enter>";
        };

        view = {
          A = ":archive flat<Enter>";
          "<C-Down>" = ":next-part<Enter>";
          "<C-j>" = ":next-part<Enter>";
          "<C-k>" = ":prev-part<Enter>";
          "<C-Left>" = ":prev<Enter>";
          "<C-l>" = ":open-link <space>";
          "<C-Right>" = ":next<Enter>";
          "<C-Up>" = ":prev-part<Enter>";
          "<C-y>" = ":copy-link <space>";
          D = ":delete<Enter>";
          f = ":forward<Enter>";
          H = ":toggle-headers<Enter>";
          J = ":next<Enter>";
          K = ":prev<Enter>";
          o = ":open<Enter>";
          O = ":open<Enter>";
          "|" = ":pipe<space>";
          q = ":close<Enter>";
          rq = ":reply -aq<Enter>";
          Rq = ":reply -q<Enter>";
          rr = ":reply -a<Enter>";
          Rr = ":reply<Enter>";
          S = ":save<space>";
          "/" = ":toggle-key-passthrough<Enter>/";
        };

        "view::passthrough" = {
          "$ex" = "<C-x>";
          "$noinherit" = true;
          "<Esc>" = ":toggle-key-passthrough<Enter>";
        };
      };

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
    notmuch.enable = true;
  };

  services.protonmail-bridge.enable = true;
}
