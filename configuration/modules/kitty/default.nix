{
  config,
  inputs,
  isNixOS,
  lib,
  pkgs,
  ...
}: {
  programs.kitty = {
    enable = true;

    extraConfig = ''
      font_features FiraCodeRoman-Regular +zero +onum +cv30 +ss09 +cv25 +cv26 +cv32 +ss07
      font_features FiraCodeRoman-SemiBold +zero +onum +cv30 +ss09 +cv25 +cv26 +cv32 +ss07
    '';

    font = {
      name = "Fira Code";
      package = pkgs.fira-code;
    };

    keybindings."kitty_mod+enter" = "launch --cwd=current --type=window";

    package =
      if isNixOS
      then pkgs.kitty
      else if pkgs.stdenv.isLinux
      then config.lib.nixGL.wrap pkgs.kitty
      # TODO: remove when kitty > 0.42.1 works on Darwin
      else inputs.nixpkgs-kitty.legacyPackages.x86_64-darwin.kitty;

    settings =
      {
        confirm_os_window_close = 0;
        enable_audio_bell = "no";
        enabled_layouts = "grid, stack, vertical, horizontal, tall";
        inactive_text_alpha = 0.5;
        include = "theme.conf";
        tab_bar_edge = "top";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        hide_window_decorations = "yes";
        macos_quit_when_last_window_closed = "yes";
        shell = "${pkgs.nushell}/bin/nu";
      }
      // lib.optionalAttrs pkgs.stdenv.isLinux {kitty_mod = "ctrl+shift";};

    themeFile = "Catppuccin-Mocha";
  };
}
