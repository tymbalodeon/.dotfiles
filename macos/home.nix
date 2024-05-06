{
  pkgs,
  pkgs-elm,
  ...
}: rec {
  home = {
    file = let
      nushell_config_path = "Library/Application Support/nushell";
    in {
      ".config/tinty/fzf.toml".source = ./tinty/fzf.toml;
      ".hushlogin".source = ./.hushlogin;
      "${nushell_config_path}/aliases.nu".source = ../nushell/aliases.nu;
      "${nushell_config_path}/cloud.nu".source = ../nushell/cloud.nu;
      "${nushell_config_path}/colors.nu".source = ../nushell/colors.nu;
      "${nushell_config_path}/f.nu".source = ../nushell/f.nu;
      "${nushell_config_path}/prompt.nu".source = ../nushell/prompt.nu;
      "${nushell_config_path}/rebuild.nu".source = ./nushell/rebuild.nu;
      "${nushell_config_path}/theme.nu".source = ../nushell/theme.nu;
      "${nushell_config_path}/theme-function.nu".source =
        ./nushell/theme-function.nu;
      "${nushell_config_path}/themes.toml".source = ../nushell/themes.toml;
      ".rustup/settings.toml".source = ./rustup/settings.toml;
    };

    homeDirectory = "/Users/benrosen";

    packages = with pkgs-elm.elmPackages; [
      elm
      elm-format
      elm-land
      elm-language-server
      elm-pages
      lamdera
    ];
  };

  imports = [../home.nix];

  programs = {
    kitty.settings = {
      font_size = "11.0";
      hide_window_decorations = "yes";
      macos_quit_when_last_window_closed = "yes";
      shell = "${home.homeDirectory}/.nix-profile/bin/nu";
    };

    nushell.extraEnv = ''
      $env.FONTCONFIG_FILE = "${
        pkgs.makeFontsConf {fontDirectories = [pkgs.freefont_ttf];}
      }"
    '';
  };
}
