{
  programs.hyprlock = {
    enable = true;

    settings = {
      background = {
        blur_passes = 2;
        path = "${../hyprpaper/hildegard.jpeg}";
      };

      general.hide_cursor = true;

      label = [
        {
          font_size = 90;
          position = "0, -25%";
          text = "$TIME12";
          valign = "top";
        }

        {
          font_size = 25;
          position = "0, -32%";
          text = ''cmd[update:43200000] date +"%A, %d %B %Y"'';
          valign = "top";
        }
      ];
    };
  };
}
