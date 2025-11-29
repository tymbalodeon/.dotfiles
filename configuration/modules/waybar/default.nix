{config, ...}: {
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

      cpu.format = "  {usage}%";

      disk = {
        format = "{used} / {total} ({percentage_used}%)";
        tooltip = false;
        unit = "GB";
      };

      "group/hardware" = {
        orientation = "inherit";
        drawer = {};

        modules = [
          "cpu"
          "memory"
          "temperature"
          "disk"
        ];
      };

      "group/network" = {
        orientation = "inherit";
        drawer = {};

        modules = [
          "network"
          "bluetooth"
        ];
      };

      "hyprland/workspaces".on-click = "activate";

      idle_inhibitor = {
        format = "{icon}";

        format-icons = {
          activated = "";
          deactivated = "";
        };

        on-click = "pgrep hypridle && systemctl --user stop hypridle || systemctl --user start hypridle";
      };

      memory.format = " {}%";

      modules-center = [
        "idle_inhibitor"
        "clock"
        "tray"
        "systemd-failed-units"
      ];

      modules-left = ["hyprland/workspaces" "hyprland/window"];

      modules-right = [
        "mpd"
        "group/hardware"
        "group/network"
        "backlight"
        "wireplumber"
        "battery"
      ];

      mpd = {
        consume-icons.on = " ";
        format-disconnected = "Disconnected";
        format = "{title}   ({elapsedTime:%M:%S}/{totalTime:%M:%S}) [{songPosition}/{queueLength}]   {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{stateIcon}";
        format-stopped = "";
        random-icons.on = " ";
        repeat-icons.on = " ";
        single-icons.on = "1 ";

        state-icons = {
          paused = "";
          playing = "";
        };

        title-len = 146;
        tooltip-format = "{album} ({albumArtist})";
      };

      network = {
        format-disconnected = "Disconnected  ⚠";
        format-ethernet = "{ipaddr}/{cidr}  ";
        format-wifi = "{essid} ({signalStrength}%)   ";
        tooltip-format = "{ifname}= {ipaddr}/{cidr}";
      };

      position = "bottom";

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
        format = "{volume}%  {icon} ";
        format-icons = ["" "" "🔊"];
        format-muted = " ";
      };
    };

    style = ''
      * {
        font-family: ${config.stylix.fonts.sansSerif.name}, "Font Awesome 7 Free"
      }
    '';
  };
}
