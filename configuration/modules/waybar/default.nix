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

      disk = {
        format = "{used} / {total} ({percentage_used}%)";
        unit = "GB";
      };

      "hyprland/workspaces".on-click = "activate";

      # TODO
      # idle_inhibitor = {
      #   format = "{icon}";

      #   format-icons = {
      #     activated = "";
      #     deactivated = "";
      #   };
      # };

      memory.format = " {}%";
      modules-center = ["clock"];
      modules-left = ["hyprland/workspaces" "hyprland/window" "tray"];

      modules-right = [
        "mpd"
        "systemd-failed-units"
        "disk"
        "temperature"
        "cpu"
        "memory"
        "bluetooth"
        "network"
        "backlight"
        "wireplumber"
        "battery"
      ];

      mpd = {
        consume-icons.on = " ";
        format-disconnected = "Disconnected";
        format = "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{title} ({elapsedTime:%M:%S}/{totalTime:%M:%S})";
        format-stopped = "⏹ Stoppped";
        random-icons.on = " ";
        repeat-icons.on = " ";
        single-icons.on = "1 ";

        state-icons = {
          paused = "";
          playing = "";
        };

        title-len = 66;
        tooltip-format = "{artist} — {album}";
      };

      network = {
        format-alt = "{ifname}= {ipaddr}/{cidr}";
        format-disconnected = "Disconnected ⚠";
        format-ethernet = "{ipaddr}/{cidr} ";
        format-wifi = "{essid} ({signalStrength}%)  ";
      };

      spacing = 8;
      systemd-failed-units.format = "✗ {nr_failed}";

      temperature = {
        critical-threshold = 80;
        format = "{temperatureF}°F";
      };

      tray = {
        icon-size = 21;
        spacing = 10;
      };

      wireplumber = {
        format = "{volume}% {icon}";
        format-icons = ["" "" ""];
        format-muted = "";
      };
    };
  };
}
