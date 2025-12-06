{
  services.hypridle = {
    enable = true;

    settings = {
      general.after_sleep_cmd = "systemctl --user restart waybar";

      listener = [
        {
          on-timeout = "nu ${../monitors/brightness.nu} dim";
          on-resume = "nu ${../monitors/brightness.nu} restore";
          timeout = 290;
        }

        {
          on-resume = "niri msg action power-on-monitors";
          on-timeout = "niri msg action power-off-monitors";
          timeout = 300;
        }

        {
          on-timeout = "systemctl suspend";
          timeout = 600;
        }
      ];
    };
  };
}
