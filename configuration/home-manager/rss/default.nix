{
  imports = [../nushell];
  nushell.extraScripts = [./rss.nu];

  programs.newsboat = {
    autoFetchArticles.enable = true;
    autoReload = true;
    autoVacuum.enable = true;
    enable = true;

    extraConfig = ''
      bind j everywhere down
      bind k everywhere up
    '';
  };
}
