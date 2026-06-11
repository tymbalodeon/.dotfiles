{
  imports = [../nushell];
  nushell.extraScripts = [{source = ./rss.nu;}];

  programs = {
    brave.extensions = [{id = "kfghpdldaipanmkhfpdcjglncmilendn";}];

    newsboat = {
      autoFetchArticles.enable = true;
      autoReload = true;
      autoVacuum.enable = true;
      enable = true;

      extraConfig = ''
        bind j everywhere down
        bind k everywhere up

        color article            default default
        color background         default default
        color end-of-text-marker color8  default
        color hint-description   default color8
        color hint-separator     default color8
        color info               color4  color8
        color listfocus          default color8 bold
        color listfocus_unread   color2 color8 bold
        color listnormal         default default
        color listnormal_unread  color2  default
        color title              color14 color8

        feed-sort-order lastupdated

        highlight article "^(Feed|Title|Author|Link|Date): .+" color4 default bold
        highlight article "^(Feed|Title|Author|Link|Date):" color14 default bold
        highlight article "\\((link|image|video)\\)" color8 default
        highlight article "https?://[^ ]+" color4 default
        highlight article "\[[0-9]+\]" color6 default bold
      '';
    };
  };
}
