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
                    check-mail = "1m";
                    check-mail-timeout = "2m";
                    copy-to = "Sent";
                    default = "tag:inbox";
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

  nushell.extraAliases = let
    mailProgram = "aerc";
  in {
    email = mailProgram;
    mail = mailProgram;
  };

  programs = {
    aerc = {
      enable = true;

      # TODO: nixify
      extraBinds = ''
        <C-c> = :prompt 'Quit?' quit<Enter>
        <C-n> = :next-tab<Enter>
        <C-PgDn> = :next-tab<Enter>
        <C-PgUp> = :prev-tab<Enter>
        <C-p> = :prev-tab<Enter>
        <C-q> = :prompt 'Quit?' quit<Enter>
        <C-t> = :term<Enter>
        <C-z> = :suspend<Enter>
        ? = :help keys<Enter>
        o = :check-mail<Enter>
        \]t = :next-tab<Enter>
        \[t = :prev-tab<Enter>

        [messages]
        q = :prompt 'Quit?' quit<Enter>

        j = :next<Enter>
        <Down> = :next<Enter>
        <C-d> = :next 50%<Enter>
        <C-f> = :next 100%<Enter>
        <PgDn> = :next 100%<Enter>

        k = :prev<Enter>
        <Up> = :prev<Enter>
        <C-u> = :prev 50%<Enter>
        <C-b> = :prev 100%<Enter>
        <PgUp> = :prev 100%<Enter>
        g = :select 0<Enter>
        G = :select -1<Enter>

        J = :next-folder<Enter>
        <C-Down> = :next-folder<Enter>
        K = :prev-folder<Enter>
        <C-Up> = :prev-folder<Enter>
        H = :collapse-folder<Enter>
        <C-Left> = :collapse-folder<Enter>
        L = :expand-folder<Enter>
        <C-Right> = :expand-folder<Enter>

        v = :mark -t<Enter>
        <Space> = :mark -t<Enter>:next<Enter>
        V = :mark -v<Enter>

        T = :toggle-threads<Enter>
        zc = :fold<Enter>
        zo = :unfold<Enter>
        za = :fold -t<Enter>
        zM = :fold -a<Enter>
        zR = :unfold -a<Enter>
        <tab> = :fold -t<Enter>

        zz = :align center<Enter>
        zt = :align top<Enter>
        zb = :align bottom<Enter>

        <Enter> = :view<Enter>
        d = :choose -o y 'Really delete this message' delete-message<Enter>
        D = :delete<Enter>
        a = :archive flat<Enter>
        A = :unmark -a<Enter>:mark -T<Enter>:archive flat<Enter>

        C = :compose<Enter>
        m = :compose<Enter>

        b = :bounce<space>

        rr = :reply -a<Enter>
        rq = :reply -aq<Enter>
        Rr = :reply<Enter>
        Rq = :reply -q<Enter>

        c = :cf<space>
        $ = :term<space>
        ! = :term<space>
        | = :pipe<space>

        / = :search<space>
        \ = :filter<space>
        n = :next-result<Enter>
        N = :prev-result<Enter>
        <Esc> = :clear<Enter>

        s = :split<Enter>
        S = :vsplit<Enter>

        pl = :patch list<Enter>
        pa = :patch apply <Tab>
        pd = :patch drop <Tab>
        pb = :patch rebase<Enter>
        pt = :patch term<Enter>
        ps = :patch switch <Tab>

        [messages:folder=Drafts]
        <Enter> = :recall<Enter>

        [view]
        / = :toggle-key-passthrough<Enter>/
        q = :close<Enter>
        O = :open<Enter>
        o = :open<Enter>
        S = :save<space>
        | = :pipe<space>
        D = :delete<Enter>
        A = :archive flat<Enter>

        <C-y> = :copy-link <space>
        <C-l> = :open-link <space>

        f = :forward<Enter>
        rr = :reply -a<Enter>
        rq = :reply -aq<Enter>
        Rr = :reply<Enter>
        Rq = :reply -q<Enter>

        H = :toggle-headers<Enter>
        <C-k> = :prev-part<Enter>
        <C-Up> = :prev-part<Enter>
        <C-j> = :next-part<Enter>
        <C-Down> = :next-part<Enter>
        J = :next<Enter>
        <C-Right> = :next<Enter>
        K = :prev<Enter>
        <C-Left> = :prev<Enter>

        [view::passthrough]
        $noinherit = true
        $ex = <C-x>
        <Esc> = :toggle-key-passthrough<Enter>

        [compose]
        # Keybindings used when the embedded terminal is not selected in the compose
        # view
        $noinherit = true
        $ex = <C-x>
        $complete = <C-o>
        <C-k> = :prev-field<Enter>
        <C-Up> = :prev-field<Enter>
        <C-j> = :next-field<Enter>
        <C-Down> = :next-field<Enter>
        <A-p> = :switch-account -p<Enter>
        <C-Left> = :switch-account -p<Enter>
        <A-n> = :switch-account -n<Enter>
        <C-Right> = :switch-account -n<Enter>
        <tab> = :next-field<Enter>
        <backtab> = :prev-field<Enter>
        <C-p> = :prev-tab<Enter>
        <C-PgUp> = :prev-tab<Enter>
        <C-n> = :next-tab<Enter>
        <C-PgDn> = :next-tab<Enter>

        [compose::editor]
        # Keybindings used when the embedded terminal is selected in the compose view
        $noinherit = true
        $ex = <C-x>
        <C-k> = :prev-field<Enter>
        <C-Up> = :prev-field<Enter>
        <C-j> = :next-field<Enter>
        <C-Down> = :next-field<Enter>
        <C-p> = :prev-tab<Enter>
        <C-PgUp> = :prev-tab<Enter>
        <C-n> = :next-tab<Enter>
        <C-PgDn> = :next-tab<Enter>

        [compose::review]
        # Keybindings used when reviewing a message to be sent
        # Inline comments are used as descriptions on the review screen
        y = :send<Enter> # Send
        n = :abort<Enter> # Abort (discard message, no confirmation)
        s = :sign<Enter> # Toggle signing
        x = :encrypt<Enter> # Toggle encryption to all recipients
        v = :preview<Enter> # Preview message
        p = :postpone<Enter> # Postpone
        q = :choose -o d discard abort -o p postpone postpone<Enter> # Abort or postpone
        e = :edit<Enter> # Edit (body and headers)
        a = :attach<space> # Add attachment
        d = :detach<space> # Remove attachment

        [terminal]
        $noinherit = true
        $ex = <C-x>

        <C-p> = :prev-tab<Enter>
        <C-n> = :next-tab<Enter>
        <C-PgUp> = :prev-tab<Enter>
        <C-PgDn> = :next-tab<Enter>
      '';

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
