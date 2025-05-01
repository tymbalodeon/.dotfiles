{
  home.file .".config/jj/config.toml".source = ./jj/config.toml;
  imports = [../../home-standalone.nix ../../../../modules/git/work.nix];
}
