{
  services.hypridle = {
    enable = true;

    settings = {
      general.after_sleep_cmd = "systemctl --user restart waybar";

      listener = [
        {
          on-timeout = "$(${../music-player/is-playing.nu}) || nu ${../monitors/brightness.nu} dim";
          on-resume = "$(${../music-player/is-playing.nu}) || nu ${../monitors/brightness.nu} restore";
          timeout = 290;
        }

        {
          on-resume = "$(${../music-player/is-playing.nu}) || niri msg action power-on-monitors";
          on-timeout = "$(${../music-player/is-playing.nu}) || niri msg action power-off-monitors";
          timeout = 300;
        }

        {
          on-timeout = "$(${../music-player/is-playing.nu}) || systemctl suspend";
          timeout = 600;
        }
      ];
    };
  };
}
