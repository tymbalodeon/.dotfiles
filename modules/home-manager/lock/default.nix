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
            rounding = 20;
            size = "288, 36";
          }
        ];

        label = let
          color = foregroundColor;
        in [
          {
            inherit color;

            font_family = "Open Sans ExtraBold";
            font_size = cfg.timeFontSize;
            position = cfg.timePosition;
            text = "$TIME12";
            valign = "top";
          }

          {
            inherit color;

            font_family = "Open Sans";
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
      default = 24;
      type = types.int;
    };

    datePosition = mkOption {
      default = "0, -810";
      type = types.str;
    };

    timeFontSize = mkOption {
      default = 120;
      type = types.int;
    };

    timePosition = mkOption {
      default = "0, -540";
      type = types.str;
    };
  };
}
