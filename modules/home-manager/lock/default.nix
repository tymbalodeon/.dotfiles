{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.lock;
in {
  config = {
    home.packages = with pkgs; [open-sans];

    programs.hyprlock = {
      enable = true;

      settings = let
        color = base16Name: "rgb(${base16Name})";
        colors = config.lib.stylix.colors;
        foregroundColor = color colors.base05;
      in {
        general.hide_cursor = true;

        input-field = lib.mkForce [
          {
            check_color = color colors.base0C;
            fade_on_empty = false;
            fail_color = color colors.base09;
            font_color = foregroundColor;
            inner_color = color colors.base01;
            outer_color = foregroundColor;
            outline_thickness = 2;
            placeholder_text = "";
            rounding = 25;
            size = "540, 48";
          }
        ];

        label = let
          color = foregroundColor;
        in [
          {
            inherit color;

            font_family = "Open Sans ExtraBold";
            font_size = cfg.timeFontSize;
            position = "0, -${toString cfg.timePosition}";
            text = "$TIME12";
            valign = "top";
          }

          {
            inherit color;

            font_family = "Open Sans Bold";
            font_size = cfg.dateFontSize;
            position = "0, -${toString cfg.datePosition}";
            text = ''cmd[update:43200000] date +"%A, %d %B %Y"'';
            valign = "top";
          }
        ];
      };
    };
  };

  # TODO: can these be determined programmatically?
  options.lock = let
    inherit (lib) mkOption types;
    screenHeight = lib.toIntBase10 (builtins.getEnv "DOTFILES_SCREEN_HEIGHT");
  in {
    dateFontSize = mkOption {
      default = 36;
      type = types.int;
    };

    datePosition = mkOption {
      default = screenHeight / 3;
      type = types.int;
    };

    timeFontSize = mkOption {
      default = 144;
      type = types.int;
    };

    timePosition = mkOption {
      default = screenHeight / 8;
      type = types.int;
    };
  };
}
