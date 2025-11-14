{
  programs.waybar = {
    enable = true;

    settings.bar = {
      backlight = {
        device = "intel_backlight";
        format = "{percent}% {icon}";
        format-icons = ["" ""];
      };

      battery = {
        format-alt = "{time} {icon}";
        format = "{capacity}% {icon}";
        format-charging = "{capacity}% ";
        format-icons = ["" "" "" "" ""];
        format-plugged = "{capacity}% ";

        states = {
          critical = 15;
          good = 75;
          warning = 30;
        };
      };

      clock = {
        calendar = {
          mode-mon-col = 3;
          mode = "year";
        };

        format = "{:%A, %d %B %Y — %I:%M %p}";
        locale = "en_GB.UTF-8";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
      };

      cpu.format = " {usage}%";
      "hyprland/workspaces".on-click = "activate";
      memory.format = " {}%";
      modules-center = ["clock"];
      modules-left = ["hyprland/workspaces" "hyprland/window"];

      modules-right = [
        "temperature"
        "cpu"
        "memory"
        "bluetooth"
        "network"
        "backlight"
        "wireplumber"
        "battery"
      ];

      network = {
        format-alt = "{ifname}= {ipaddr}/{cidr}";
        format-disconnected = "Disconnected ⚠";
        format-ethernet = "{ipaddr}/{cidr} ";
        format-wifi = "{essid} ({signalStrength}%)  ";
      };

      spacing = 8;

      temperature = {
        critical-threshold = 80;
        format = "{temperatureF}°F";
      };

      wireplumber = {
        format = "{volume}% {icon}";
        format-icons = ["" "" ""];
        format-muted = "";
      };
    };
  };
}
