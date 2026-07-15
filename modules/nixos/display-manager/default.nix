{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    cfg = config.displayManager;

    sddmTheme = let
      backgroundColor = "${colors.base00}";
      colors = config.lib.stylix.colors.withHashtag;
      fontSize = 24;
      foregroundColor = "${colors.base05}";
    in
      pkgs.where-is-my-sddm-theme.override
      {
        themeConfig.General = {
          backgroundFill = backgroundColor;
          basicTextColor = foregroundColor;
          cursorBlinkAnimation = false;
          hideCursor = true;
          passwordCursorColor = foregroundColor;
          passwordFontSize = fontSize;
          passwordTextColor = foregroundColor;
        };
      };
  in {
    environment.systemPackages = with pkgs; [
      bibata-cursors
      sddmTheme
    ];

    services.displayManager = let
      cursorSize = 24;
      cursorTheme = "Bibata-Modern-Classic";
    in {
      inherit (cfg) defaultSession;

      sddm = {
        enable = true;
        extraPackages = [sddmTheme];

        settings = {
          AutoLogin.User = config.nixos.username;

          Theme = {
            CursorSize = cursorSize;
            CursorTheme = cursorTheme;
          };
        };

        theme = "where_is_my_sddm_theme";
        wayland.enable = true;
      };
    };
  };

  options.displayManager.defaultSession = let
    inherit (lib) mkOption types;
  in
    mkOption {
      default = "niri";
      type = types.str;
    };
}
