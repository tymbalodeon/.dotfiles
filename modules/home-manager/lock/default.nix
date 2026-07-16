{
  config,
  lib,
  ...
}: {
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
            font_family = config.stylix.fonts.sansSerif.name;
            inner_color = color colors.base01;
            outer_color = foregroundColor;
            outline_thickness = 2;
            placeholder_text = "";
            rounding = 1;
            size = "288, 48";
          }
        ];

        label = let
          baseFontSize = config.stylix.fonts.sizes.desktop;
        in [
          {
            color = foregroundColor;
            font_size = baseFontSize * 3;
            position = config.lock.timePosition;
            text = "$TIME12";
            valign = "top";
          }

          {
            color = foregroundColor;
            font_size = baseFontSize;
            position = config.lock.datePosition;
            text = ''cmd[update:43200000] date +"%A, %d %B %Y"'';
            valign = "top";
          }
        ];
      };
    };
  };

  options.lock = {
    datePosition = lib.mkOption {
      default = "0, -30%";
      type = lib.types.str;
    };

    timePosition = lib.mkOption {
      default = "0, -22%";
      type = lib.types.str;
    };
  };
}
