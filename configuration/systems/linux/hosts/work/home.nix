{
  home.file = {
    ".config/jj/config.toml".source = ./jj/config.toml;
    ".gitconfig".source = ./git/.gitconfig;
  };

  imports = [../../standalone-home.nix];
}
