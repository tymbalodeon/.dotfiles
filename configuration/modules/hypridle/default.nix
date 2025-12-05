{
  services.hypridle = {
    enable = true;

    settings.listener = [
      {
        on-timeout = "nu ${../monitors/brightness.nu} set min";
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
}
