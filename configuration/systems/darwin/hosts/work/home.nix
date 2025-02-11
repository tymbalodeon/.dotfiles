{pkgs, ...}: {
  home = {
    file = {
      ".gitconfig".source = ./git/.gitconfig;
      "Library/Application Support/jj/config.toml".source = ./jj/config.toml;
    };

    packages = with pkgs; [
      pdm
      rufo
      solargraph
    ];
  };

  imports = [../../home.nix];
}
