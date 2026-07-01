{
  config,
  lib,
  ...
}: {
  programs.hyprlock = {
    enable = true;

    settings = let
      backgroundColor = color colors.base00;
      color = base16Name: "rgb(${base16Name})";
      colors = config.lib.stylix.colors;
      foregroundColor = color colors.base05;
    in {
      general.hide_cursor = true;

      input-field = lib.mkForce [
        {
          check_color = color colors.base0C;
          dots_size = 0.2;
          fade_on_empty = false;
          fail_color = color colors.base09;
          font_color = foregroundColor;
          font_family = config.stylix.fonts.sansSerif.name;
          inner_color = backgroundColor;
          outer_color = backgroundColor;
          outline_thickness = 2;
          placeholder_text = "<i>Input password...</i>";
          size = "288, 48";
        }
      ];

      label = [
        {
          color = foregroundColor;
          font_size = 48;
          position = "0, -22%";
          text = "$TIME12";
          valign = "top";
        }

        {
          color = foregroundColor;
          font_size = 16;
          position = "0, -30%";
          text = ''cmd[update:43200000] date +"%A, %d %B %Y"'';
          valign = "top";
        }
      ];
    };
  };
}
