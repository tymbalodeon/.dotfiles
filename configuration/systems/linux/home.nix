{
  home = {
    file = {
      ".config/nushell/theme-function.nu".source = ./modules/nushell/theme-function.nu;
      ".config/tinty/fzf.toml".source = ./modules/tinty/fzf.toml;
    };

    homeDirectory = "/home/benrosen";
  };

  imports = [
    ../../home.nix
    ./modules/fonts
    ./modules/ghostty
    ./modules/kitty
  ];
}
