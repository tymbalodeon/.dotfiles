{pkgs, ...}: {
  home = {
    file = {
      ".config/tinty/fzf.toml".source =
        if pkgs.stdenv.isDarwin
        then ./fzf-darwin.toml
        else ./fzf-linux.toml;

      ".config/tinty/helix.toml".source = ./helix.toml;
      ".config/tinty/kitty.toml".source = ./kitty.toml;
      ".config/tinty/shell.toml".source = ./shell.toml;
    };

    packages = [pkgs.tinty];
  };
}
