{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = let
    cfg = config.kitty;
  in {
    home.packages = [pkgs.fira-code];

    programs.kitty = let
      inherit (pkgs.stdenv) isDarwin isLinux;
    in {
      enable = true;

      extraConfig = ''
        font_features FiraCodeRoman-Regular +zero +onum +cv30 +ss09 +cv25 +cv26 +cv32 +ss07
        font_features FiraCodeRoman-SemiBold +zero +onum +cv30 +ss09 +cv25 +cv26 +cv32 +ss07
      '';

      keybindings."kitty_mod+enter" = "launch --cwd=current --type=window";

      package =
        if isLinux
        then config.lib.nixGL.wrap pkgs.kitty
        else pkgs.kitty;

      settings =
        {
          confirm_os_window_close = 0;
          enable_audio_bell = "no";
          enabled_layouts = "grid, stack, vertical, horizontal, tall";
          font_family = "Fira Code";
          font_size = cfg.font_size;
          inactive_text_alpha = 0.5;
          include = "theme.conf";
          shell = "${pkgs.nushell}/bin/nu";
          tab_bar_edge = "top";
          tab_bar_style = "powerline";
          tab_powerline_style = "slanted";
        }
        // lib.optionalAttrs isDarwin {
          hide_window_decorations = "yes";
          macos_quit_when_last_window_closed = "yes";
        }
        // lib.optionalAttrs isLinux {kitty_mod = "ctrl+shift";};

      themeFile = "Catppuccin-Mocha";
    };
  };

  options.kitty = with types; {
    font_size = mkOption {
      default = 8.0;
      type = float;
    };
  };
}
