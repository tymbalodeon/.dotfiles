{
  lib,
  pkgs,
  ...
}: {
  home.file.".config/kitty/theme.conf".source = ./theme.conf;

  programs.kitty = {
    enable = true;

    extraConfig = ''
      map kitty_mod+enter launch --cwd=current --type=window
      font_features FiraCodeRoman-Regular +zero +onum +cv30 +ss09 +cv25 +cv26 +cv32 +ss07
      font_features FiraCodeRoman-SemiBold +zero +onum +cv30 +ss09 +cv25 +cv26 +cv32 +ss07
    '';

    settings =
      {
        confirm_os_window_close = 0;
        enable_audio_bell = "no";
        enabled_layouts = "grid, stack, vertical, horizontal, tall";
        font_family = "Fira Code";
        font_size = 11;
        inactive_text_alpha = 0.5;
        include = "theme.conf";
        tab_bar_edge = "top";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
      }
      // lib.optionalAttrs pkgs.stdenv.isLinux {kitty_mod = "ctrl+shift";};
  };
}
