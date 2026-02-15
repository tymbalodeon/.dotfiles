{paneru, ...}: {
  imports = [paneru.homeModules.paneru];

  services.paneru = {
    enable = true;

    settings = {
      bindings = {
        quit = "ctrl + alt - q";
        window_center = "alt - c";
        window_focus_east = "cmd - l";
        window_focus_north = "cmd - k";
        window_focus_south = "cmd - j";
        window_focus_west = "cmd - h";
        window_fullwidth = "alt - f";
        window_manage = "ctrl + alt - t";
        window_resize = "alt - r";
        window_stack = "alt - ]";
        window_swap_east = "alt - l";
        window_swap_first = "alt + shift - h";
        window_swap_last = "alt + shift - l";
        window_swap_west = "alt - h";
        window_unstack = "alt + shift - ]";
      };

      options = {
        animation_speed = 4000;

        preset_column_widths = [
          0.25
          0.33
          0.5
          0.66
          0.75
        ];

        swipe_gesture_fingers = 4;
      };
    };
  };
}
