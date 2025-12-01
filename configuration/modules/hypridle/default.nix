{
  services.hypridle = {
    enable = true;

    settings = {
      listener = [
        {
          timeout = 300;
          on-resume = "hyprctl dispatch dpms on";
          on-timeout = "hyprctl dispatch dpms off";
        }

        {
          on-timeout = "systemctl suspend";
          timeout = 600;
        }
      ];
    };
  };
}
