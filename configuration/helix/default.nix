{
  home.file = {
    ".config/helix/config.toml".source = ./config.toml;
    ".config/helix/languages.toml".source = ./languages.toml;
    ".config/helix/themes/theme.toml".source = ./themes/theme.toml;
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
  };
}
