{ ... }:

rec {
  imports = [ ../home.nix ];

  home = {
    file = let
      nushell_config_path =
        "${home.homeDirectory}/Library/Application Support/nushell";
    in {
      ".hushlogin".source = ./.hushlogin;
      "${nushell_config_path}/colors.nu".source = ../nushell/colors.nu;
      "${nushell_config_path}/prompt.nu".source = ../nushell/prompt.nu;
      "${nushell_config_path}/theme.nu".source = ../nushell/theme.nu;
    };

    homeDirectory = "/Users/benrosen";
  };

  programs.kitty.settings = {
    font_size = "11.0";
    hide_window_decorations = "yes";
    macos_quit_when_last_window_closed = "yes";
    shell = "${home.homeDirectory}/.nix-profile/bin/nu";
  };
}
