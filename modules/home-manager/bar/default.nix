{
  config,
  lib,
  ...
}: {
  config = let
    cfg = config.waybar;
  in {
    programs.waybar = {
      enable = true;

      settings = let
        backlight = {
          device = "intel_backlight";
          format = "{icon} {percent} %";
          format-icons = ["" ""];
          tooltip = false;
        };

        battery = {
          format-charging = " {capacity} %";
          format = "{icon} {capacity} %";
          format-icons = ["" "" "" ""];
          format-plugged = " {capacity} %";
        };

        bluetooth = {
          # TODO: figure out why this is necessary
          format =
            if cfg.laptop
            then " {status}"
            else null;

          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
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

        cpu.format = " {usage} %";

        "custom/brightness" = {
          exec = "nu ${../monitors/brightness.nu} get";
          format = " {text} %";
          interval = "once";
          on-click = "nu ${../monitors/brightness.nu} set min";
          on-click-right = "nu ${../monitors/brightness.nu} set max";
          on-scroll-down = "nu ${../monitors/brightness.nu} decrease";
          on-scroll-up = "nu ${../monitors/brightness.nu} increase";
          signal = 1;
          tooltip = false;
        };

        "custom/media" = {
          escape = true;
          exec-if = "pgrep playerctld";
          exec = "${./media.nu}";
          on-click = "playerctl play-pause";
          on-click-right = "playerctl stop";
          restart-interval = 1;
          return-type = "json";
        };

        "custom/moon-phase" = {
          "exec" = "${./moon.sh}";
          "format" = "{text}";
          "interval" = 3600;
          "return-type" = "json";
          "tooltip" = true;
        };

        "custom/power" = {
          format = "⏻  ";

          menu-actions = {
            hibernate = "systemctl hibernate";
            reboot = "reboot";
            shutdown = "shutdown";
            suspend = "systemctl suspend";
          };

          menu-file = "${./power_menu.xml}";
          menu = "on-click";
          tooltip = false;
        };

        "custom/weather" = {
          "exec" = "${./weather.sh}";
          "format" = "{text}";
          "interval" = fiveMinutes;
          "return-type" = "json";
          "tooltip" = true;
        };

        "custom/weather-temperature" = {
          "exec" = "${./weather.sh} temperature";
          "format" = "{text}";
          "interval" = fiveMinutes;
          "return-type" = "json";
          "tooltip" = true;
        };

        disk = {
          format = " {percentage_used} %";
          tooltip-format = "Used: {used}\nRemaining: {free}\nTotal: {total}";
          unit = "GB";
        };

        "custom/sunsetr" = {
          exec = "nu ${../sunsetr/sunsetr.nu} get";
          interval = oneHour;
          on-click = "nu ${../sunsetr/sunsetr.nu} toggle";
          return-type = "json";
          signal = 3;
        };

        "custom/systemd-failed-units" = {
          exec = "${./systemd-failed-units.nu}";
          format = "✗ {}";
          hide-empty-text = true;
          interval = oneMinute;
          return-type = "json";
        };

        "custom/wallpaper" = {
          escape = true;
          exec-if = "pgrep swaybg || pgrep wpaperd";
          exec = "nu ${../wallpaper/wallpaper-status.nu}";
          format = " {}";
          hide-empty-text = true;
          interval = oneMinute;
          on-click-middle = "nu ${../wallpaper/wallpaper.nu} toggle-pause";
          on-click = "nu ${../wallpaper/wallpaper.nu} next";
          on-click-right = "nu ${../wallpaper/wallpaper.nu} previous";
          return-type = "json";
          signal = 2;
        };

        fiveMinutes = 300;

        "group/system" = {
          drawer = {};

          modules = [
            "cpu"
            "memory"
            "disk"
            "temperature"
          ];

          orientation = "inherit";
        };

        height = 40;

        idle_inhibitor = {
          format = "{icon}";

          format-icons = {
            activated = "";
            deactivated = "";
          };

          # TODO: put this in a script in the idle module, so that changing the
          # program for idling doesn't require editing unrelated module files
          on-click = "pgrep hypridle && systemctl --user stop hypridle || systemctl --user start hypridle";
          timeout = 720;
        };

        memory.format = " {} %";

        mpd = {
          consume-icons.on = " ";
          format = "\"{title}\" by {albumArtist}  ({elapsedTime:%M:%S}/{totalTime:%M:%S}) [{songPosition}/{queueLength}]  {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{stateIcon}";
          format-disconnected = "Disconnected";
          format-stopped = "";
          on-click-right = "rmpc stop";
          on-click = "rmpc togglepause";
          random-icons.on = " ";
          repeat-icons.on = " ";
          single-icons.on = "1 ";

          state-icons = {
            paused = "";
            playing = "";
          };

          title-len = 146;
          tooltip-format = "Album: \"{album}\"";
        };

        network = {
          format-disconnected = "⚠ Disconnected";
          format-ethernet = " {ipaddr}/{cidr}";
          format-wifi = " {essid} ({signalStrength} %)";
          tooltip-format = "{ifname}= {ipaddr}/{cidr}";
        };

        "niri/window".tooltip = false;

        "niri/workspaces" = {
          current-only = cfg.laptop;
          disable-click = cfg.laptop;
        };

        oneHour = 3600;
        oneMinute = 60;

        temperature = {
          critical-threshold = 80;
          format = " {temperatureF} °F";
        };

        tray.spacing = 4;

        wireplumber = {
          format = "{icon} {volume} % ";
          format-icons = ["" "" ""];
          format-muted = " ";
        };
      in {
        bottom = {
          inherit
            "backlight"
            "custom/brightness"
            "custom/media"
            "custom/moon-phase"
            "custom/sunsetr"
            "custom/weather"
            height
            "mpd"
            "wireplumber"
            ;

          modules-center = [
            "custom/moon-phase"
            "custom/weather-temperature"
            "custom/weather"
          ];

          modules-left = [
            "custom/media"
            "mpd"
          ];

          modules-right =
            [
              "custom/sunsetr"
            ]
            ++ (
              if cfg.laptop
              then ["backlight"]
              else ["custom/brightness"]
            )
            ++ ["wireplumber"];

          position = "bottom";
          spacing = 12;
        };

        top = {
          inherit
            "battery"
            "bluetooth"
            "clock"
            "cpu"
            "custom/power"
            "custom/systemd-failed-units"
            "custom/wallpaper"
            "disk"
            "group/system"
            height
            "idle_inhibitor"
            "memory"
            "network"
            "niri/window"
            "niri/workspaces"
            "temperature"
            "tray"
            ;

          modules-center = [
            "idle_inhibitor"
            "clock"
            "custom/wallpaper"
            "tray"
            "custom/systemd-failed-units"
          ];

          modules-left = [
            "niri/workspaces"
            "niri/window"
          ];

          modules-right =
            (
              if cfg.laptop
              then ["group/system"]
              else "group/system".modules
            )
            ++ [
              "bluetooth"
              "network"
            ]
            ++ (
              if cfg.laptop
              then [
                "battery"
              ]
              else []
            )
            ++ [
              "custom/power"
            ];

          position = "top";
          spacing = 12;
        };
      };

      style = let
        font = config.stylix.fonts.sansSerif.name;
        size = toString (config.stylix.fonts.sizes.desktop + 4);
      in
        lib.mkAfter ''* { font-family: ${font}, "Font Awesome 7 Free"; font-size: ${size}px; }'';

      systemd.enable = true;
    };
  };

  imports = [../weather];

  options.waybar = with lib; {
    laptop = mkOption {
      default = config.laptop;
      type = types.bool;
    };
  };
}
