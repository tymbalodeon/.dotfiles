{
  home = {
    file = {
      ".config/helix/config.toml".source = ./config.toml;
      ".config/helix/themes/theme.toml".source = ./themes/theme.toml;
    };

    sessionVariables = {EDITOR = "hx";};
  };

  imports = [
    ./bash
    ./json
    ./markdown
    ./nix
    ./toml
    ./txt
    ./yaml
  ];

  programs.helix = {
    defaultEditor = true;
    enable = true;
  };
}
