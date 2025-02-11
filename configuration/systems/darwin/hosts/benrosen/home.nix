{...}: {
  home.file = {
    ".gitconfig".source = ../../../../git/.gitconfig;
    "Library/Application Support/jj/config.toml".source = ../../../../jj/config.toml;
  };

  imports = [../../home.nix];
}
