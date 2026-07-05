{
  config,
  lib,
  pkgs,
  ...
}: let
  email = config.user.email;
in {
  # FIXME
  accounts.email = {
    accounts.${email} = {
      address = "${email}";
      flavor = "gmail.com";

      neomutt = {
        enable = true;

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

          # set folder = "imaps://imap.gmail.com:993"
          set imap_user = "${email}"
          set index_format = "%4C %zs %{%Y %b %d} %-20.20L %s"
          set postponed = "+[Gmail]/Drafts"
          set record = "+[Gmail]/Sent Mail"
          set sleep_time = 0
          set smtp_url = "smtps://${email}@smtp.gmail.com:465/"
          set sort = reverse-date
          set spoolfile = "+INBOX"
        '';
      };

      notmuch = {
        enable = true;
        neomutt.enable = true;
      };

      passwordCommand = "${lib.getExe pkgs.nushell} ${./account-command.nu}";
      primary = true;
      realName = config.user.name;
    };

    maildirBasePath = "Mail";
  };

  imports = [
    ../secrets
    ../shell/nushell
  ];

  nushell.extraScripts = [{source = ./mail.nu;}];

  programs.neomutt = {
    enable = true;
    vimKeys = true;
  };

  sops.secrets."gmail/password" = {};
}
