{
  config,
  lib,
  ...
}: let
  cfg = config.lock;
in {
  config = {
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
            rounding = 24;
            size = "288, 36";
          }
        ];

        label = let
          color = foregroundColor;
          font_family = config.stylix.fonts.serif.name;
        in [
          {
            inherit color font_family;

            font_size = cfg.timeFontSize;
            position = cfg.timePosition;
            text = "$TIME12";
            valign = "top";
          }

          {
            inherit color font_family;

            font_size = cfg.dateFontSize;
            position = cfg.datePosition;
            text = ''cmd[update:43200000] date +"%A, %d %B %Y"'';
            valign = "top";
          }
        ];
      };
    };
  };

  options.lock = let
    inherit (lib) mkOption types;
  in {
    dateFontSize = mkOption {
      default = config.stylix.fonts.sizes.desktop + 16;
      type = types.int;
    };

    datePosition = mkOption {
      default = "0, -32%";
      type = types.str;
    };

    timeFontSize = mkOption {
      default = config.stylix.fonts.sizes.desktop + 84;
      type = types.int;
    };

    timePosition = mkOption {
      default = "0, -18%";
      type = types.str;
    };
  };
}
