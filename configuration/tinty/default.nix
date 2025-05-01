{pkgs, ...}: {
  home = {
    file = {
      ".config/tinty/helix.toml".source = ./helix.toml;
      ".config/tinty/kitty.toml".source = ./kitty.toml;
      ".config/tinty/shell.toml".source = ./shell.toml;
    };

    packages = [pkgs.tinty];
  };
}
