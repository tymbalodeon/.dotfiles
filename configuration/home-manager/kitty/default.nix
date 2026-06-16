{
  config,
  hostType,
  lib,
  pkgs,
  ...
}: {
  config = let
    cfg = config.kitty;
  in {
    home.packages = [pkgs.fira-code];

    programs.kitty =
      {
        enable = true;

        extraConfig = ''
          font_features FiraCodeRoman-Regular +zero +onum +cv30 +ss09 +cv25 +cv26 +cv32 +ss07
          font_features FiraCodeRoman-SemiBold +zero +onum +cv30 +ss09 +cv25 +cv26 +cv32 +ss07
        '';

        font = {
          # TODO: pull this value from a single file that can be read here as
          # well as by the stylix file
          name =
            if hostType == "home-manager"
            then "Iosevka"
            else config.stylix.fonts.monospace.name;

          # TODO: figure out why lib.mkForce is necessary
          size = lib.mkForce cfg.fontSize;
        };

        keybindings = {
          "ctrl+shift+h" = "launch --stdin-source=@screen_scrollback hx";
          "ctrl+o" = "open_url_with_hints";
          "kitty_mod+enter" = "launch --cwd last_reported --type window";
        };

        package = config.lib.nixGL.wrap pkgs.kitty;

        settings =
          {
            confirm_os_window_close = 0;
            enable_audio_bell = "no";
            enabled_layouts = "grid, stack, vertical, horizontal, tall";
            inactive_text_alpha = 0.5;

            # TODO: is there a way to pull this value programmatically?
            italic_font = "Iosevka Italic";

            kitty_mod = "ctrl+shift";
            shell = lib.getExe pkgs.nushell;
            tab_bar_edge = "top";
            tab_bar_style = "powerline";
            tab_powerline_style = "slanted";
            wheel_scroll_multiplier = 1;
          }
          // lib.optionalAttrs (hostType == "home-manager") {
            # TODO: is there a way to pull this value programmatically?
            font_family = "Iosevka";
          };
      }
      // lib.optionalAttrs (hostType == "home-manager") {
        themeFile = "Catppuccin-Macchiato";
      };
  };

  options.kitty.fontSize = with lib;
    mkOption {
      default = 9.0;
      type = types.float;
    };
}
