{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = let
    cfg = config.hypr;
    configDirectory = config.nushell.configDirectory;
    wallpaper = ./wallpaper/hildegard.jpeg;
  in {
    home = {
      file = {
        "${configDirectory}/hyprland-is-muted.nu".source = ./hyprland-is-muted.nu;

        "${configDirectory}/hyprland-set-follow-mouse.nu".source =
          ./hyprland-set-follow-mouse.nu;

        "${configDirectory}/hyprland-set-gaps.nu".source = ./hyprland-set-gaps.nu;
      };

      packages = with pkgs;
        [
          hyprpicker
        ]
        ++ (
          if cfg.laptop
          then [brightnessctl]
          else []
        );
    };

    programs.hyprlock = {
      enable = true;

      settings = {
        background = {
          blur_passes = 2;
          path = "${wallpaper}";
        };

        general.hide_cursor = true;

        label = [
          {
            font_size = 90;
            position = "0, -25%";
            text = "$TIME12";
            valign = "top";
          }

          {
            font_size = 25;
            position = "0, -32%";
            text = ''cmd[update:43200000] date +"%A, %d %B %Y"'';
            valign = "top";
          }
        ];
      };
    };

    services = {
      hypridle = {
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

      hyprpaper = {
        enable = true;

        settings = {
          preload = "${wallpaper}";
          wallpaper = [", ${wallpaper}"];
        };
      };

      playerctld.enable = true;
    };

    wayland.windowManager.hyprland = {
      enable = true;

      settings = {
        bind = [
          "$mainMod, 0, workspace, 10"
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, delete, exit"
          "$mainMod, F, fullscreen"
          "$mainMod, G, exec, nu ~/.config/nushell/hyprland-set-gaps.nu"
          "$mainMod, H, workspace, -1"
          "$mainMod, J, cyclenext, prev"
          "$mainMod, K, cyclenext"
          "$mainMod, L, workspace, +1"
          "$mainMod, M, exec, nu ~/.config/nushell/hyprland-set-follow-mouse.nu"
          "$mainMod, Q, killactive,"
          "$mainMod, R, exec, hyprctl reload"
          "$mainMod SHIFT, 0, movetoworkspace, 10"
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, F, fullscreen, 1"
          "$mainMod SHIFT, H, movetoworkspace, -1"
          "$mainMod SHIFT, I, resizeactive, 0 25"
          "$mainMod SHIFT, J, layoutmsg, rollprev"
          "$mainMod SHIFT, K, layoutmsg, rollnext"
          "$mainMod SHIFT, L, movetoworkspace, +1"
          "$mainMod SHIFT, N, exec, swaync-client --toggle-panel --skip-wait"
          "$mainMod SHIFT, O, resizeactive, 0 -25"
          "$mainMod SHIFT, P, resizeactive, 25 0"
          "$mainMod SHIFT, S, movetoworkspace, special:magic"
          "$mainMod SHIFT, space, exec, rofi -show window"
          "$mainMod SHIFT, U, resizeactive, -25 0"
          "$mainMod, space, exec, rofi -show drun"
          "$mainMod, S, togglespecialworkspace, magic"
          "$mainMod, T, exec, kitty"
          "$mainMod, V, exec, cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy"
          "$mainMod, W, exec, pkill waybar || waybar; systemctl --user start hypridle"
        ];

        bindel =
          [
            ", XF86AudioLowerVolume, exec, nu ~/.config/nushell/hyprland-is-muted.nu && wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"
            ", XF86AudioNext, exec, rmpc next"
            ", XF86AudioPlay, exec, playerctl play-pause; rmpc togglepause"
            ", XF86AudioPrev, exec, rmpc prev"
            ", XF86AudioRaiseVolume, exec, nu ~/.config/nushell/hyprland-is-muted.nu && wpctl set-volume --limit 1.0 @DEFAULT_AUDIO_SINK@ 1%+"
          ]
          ++ cfg.hyprland.settings.bindelExtra;

        bindl = [", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"];

        ecosystem = {
          no_donation_nag = true;
          no_update_news = true;
        };

        env = [
          "QT_QPA_PLATFORMTHEME,qt5ct"
          "XCURSOR_SIZE,16"
        ];

        exec-once = ["waybar"];

        general = {
          allow_tearing = false;
          gaps_in = 8;
          gaps_out = 16;
          layout = "master";
        };

        input = {
          kb_options = cfg.hyprland.settings.input.kb_options;
          repeat_delay = 200;
          repeat_rate = 50;
        };

        "$mainMod" = "SUPER";
        misc.force_default_wallpaper = 0;
        monitor = cfg.hyprland.settings.monitor;
      };
    };
  };

  imports = [
    ../nushell
    ../rofi
  ];

  options.hypr = with types; {
    hyprland.settings = {
      bindelExtra = mkOption {
        default = [];
        type = listOf str;
      };

      input.kb_options = mkOption {
        default = "caps:escape";
        type = str;
      };

      monitor = mkOption {
        default = ", preferred, auto, auto";
        type = str;
      };
    };

    laptop = mkOption {
      default = false;
      type = bool;
    };
  };
}
