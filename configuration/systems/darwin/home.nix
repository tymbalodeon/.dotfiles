rec {
  home = {
    file = {
      ".hushlogin".source = ./.hushlogin;
      ".rustup/settings.toml".source = ./rustup/settings.toml;
    };

    homeDirectory = "/Users/benrosen";
  };

  imports = [
    ../../home.nix
    {programs.nushell.configDirectory = "Library/Application Support/nushell";}
  ];

  programs.kitty.settings = {
    hide_window_decorations = "yes";
    macos_quit_when_last_window_closed = "yes";
    shell = "${home.homeDirectory}/.nix-profile/bin/nu";
  };
}
