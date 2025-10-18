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

      # FIXME
      clock = {
        calendar = {
          format.weeks = "{=%W}";
          mode-mon-col = 3;
          mode = "year";
        };

        format = "{=%I=%M %p}";
        format-alt = "{=%A, %B %d, %Y (%I=%M %p)}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
      };

      cpu.format = "{usage}% ";

      "hyprland/window" = {
        format = "{}";

        rewrite = {
          "(.*) — Mozilla Firefox" = "   $1";
          "(.*)nu" = " ";
        };
      };

      "hyprland/workspaces" = {
        on-click = "activate";
        sort-by-number = true;
      };

      idle_inhibitor = {
        format = "{icon}";

        format-icons = {
          activated = "";
          deactivated = "";
        };
      };

      layer = "top";
      memory.format = "{}% ";
      modules-center = ["clock"];
      modules-left = ["hyprland/workspaces" "hyprland/window"];

      modules-right = [
        "idle_inhibitor"
        "temperature"
        "cpu"
        "memory"
        "network"
        "backlight"
        "wireplumber"
        "battery"
      ];

      network = {
        format-alt = "{ifname}= {ipaddr}/{cidr}";
        format-disconnected = "Disconnected ⚠";
        format-ethernet = "{ipaddr}/{cidr} ";
        format-wifi = "{essid} ({signalStrength}%) ";
      };

      spacing = 4;

      temperature = {
        critical-threshold = 80;
        format = "{temperatureF}°F {icon}";
        format-icons = ["" "" ""];
      };

      wireplumber = {
        format = "{volume}% {icon}";
        format-icons = ["" "" ""];
        format-muted = "";
      };
    };
  };
}
