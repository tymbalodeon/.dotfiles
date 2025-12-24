{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  defaultXkbOptions = "caps:escape";
in {
  config = let
    cfg = config.niri;
  in {
    home = {
      activation.niri =
        lib.hm.dag.entryAfter ["writeBoundary"]
        ''mkdir --parents ~/Pictures/Screenshots'';

      packages = with pkgs;
        [
          gnome-keyring
          xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
          xwayland-satellite
        ]
        ++ (
          if config.laptop
          then [pkgs.brightnessctl]
          else []
        );
    };

    xdg.configFile."niri/config.kdl" = {
      force = true;

      text = let
        binds =
          ''
            Mod+1 { focus-workspace 1; }
            Mod+2 { focus-workspace 2; }
            Mod+3 { focus-workspace 3; }
            Mod+4 { focus-workspace 4; }
            Mod+5 { focus-workspace 5; }
            Mod+6 { focus-workspace 6; }
            Mod+7 { focus-workspace 7; }
            Mod+8 { focus-workspace 8; }
            Mod+9 { focus-workspace 9; }
            Mod+BracketLeft { consume-or-expel-window-left; }
            Mod+BracketRight { consume-or-expel-window-right; }
            Mod+C { center-column; }
            Mod+Comma { consume-window-into-column; }
            Mod+Ctrl+1 { move-column-to-workspace 1; }
            Mod+Ctrl+2 { move-column-to-workspace 2; }
            Mod+Ctrl+3 { move-column-to-workspace 3; }
            Mod+Ctrl+4 { move-column-to-workspace 4; }
            Mod+Ctrl+5 { move-column-to-workspace 5; }
            Mod+Ctrl+6 { move-column-to-workspace 6; }
            Mod+Ctrl+7 { move-column-to-workspace 7; }
            Mod+Ctrl+8 { move-column-to-workspace 8; }
            Mod+Ctrl+9 { move-column-to-workspace 9; }
            Mod+Ctrl+C { center-visible-columns; }
            Mod+Ctrl+Down { move-window-down; }
            Mod+Ctrl+End { move-column-to-last; }
            Mod+Ctrl+F { expand-column-to-available-width; }
            Mod+Ctrl+H { move-column-left; }
            Mod+Ctrl+Home { move-column-to-first; }
            Mod+Ctrl+J { move-window-down; }
            Mod+Ctrl+K { move-window-up; }
            Mod+Ctrl+Left { move-column-left; }
            Mod+Ctrl+L { move-column-right; }
            Mod+Ctrl+N { move-column-to-workspace-down; }
            Mod+Ctrl+P { move-column-to-workspace-up; }
            Mod+Ctrl+Right { move-column-right; }
            Mod+Ctrl+R { reset-window-height; }
            Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
            Mod+Ctrl+Shift+WheelScrollUp { move-column-left; }
            Mod+Ctrl+Up { move-window-up; }
            Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
            Mod+Ctrl+WheelScrollLeft { move-column-left; }
            Mod+Ctrl+WheelScrollRight { move-column-right; }
            Mod+Ctrl+WheelScrollUp cooldown-ms=150 { move-column-to-workspace-up; }
            Mod+Down { focus-window-down; }
            Mod+End { focus-column-last; }
            Mod+Equal { set-column-width "+10%"; }
            Mod+F { maximize-column; }
            Mod+H { focus-column-left; }
            Mod+Home { focus-column-first; }
            Mod+J { focus-window-down; }
            Mod+K { focus-window-up; }
            Mod+Left { focus-column-left; }
            Mod+L { focus-column-right; }
            Mod+Minus { set-column-width "-10%"; }
            Mod+M hotkey-overlay-title="Open music player" { spawn-sh "kitty --hold rmpc"; }
            Mod+N { focus-workspace-down; }
            Mod+O repeat=false { toggle-overview; }
            Mod+Page_Up { focus-workspace-up; }
            Mod+Period { expel-window-from-column; }
            Mod+P { focus-workspace-up; }
            Mod+Q repeat=false { close-window; }
            Mod+Right { focus-column-right; }
            Mod+R { switch-preset-column-width; }
            Mod+Shift+Ctrl+Down { move-column-to-monitor-down; }
            Mod+Shift+Ctrl+H { move-column-to-monitor-left; }
            Mod+Shift+Ctrl+J { move-column-to-monitor-down; }
            Mod+Shift+Ctrl+K { move-column-to-monitor-up; }
            Mod+Shift+Ctrl+Left { move-column-to-monitor-left; }
            Mod+Shift+Ctrl+L { move-column-to-monitor-right; }
            Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
            Mod+Shift+Ctrl+Up { move-column-to-monitor-up; }
            Mod+Shift+Down { focus-monitor-down; }
            Mod+Shift+Equal { set-window-height "+10%"; }
            Mod+Shift+F hotkey-overlay-title="Make the window fullscreen" { fullscreen-window; }
            Mod+Shift+H { focus-monitor-left; }
            Mod+Shift+J { focus-monitor-down; }
            Mod+Shift+K { focus-monitor-up; }
            Mod+Shift+Left { focus-monitor-left; }
            Mod+Shift+L { focus-monitor-right; }
            Mod+Shift+Minus { set-window-height "-10%"; }
            Mod+Shift+N hotkey-overlay-title="Open notifications panel" { spawn "swaync-client" "--toggle-panel" "--skip-wait"; }
            Mod+Shift+Right { focus-monitor-right; }
            Mod+Shift+R { switch-preset-window-height; }
            Mod+Shift+Slash { show-hotkey-overlay; }
            Mod+Shift+Up { focus-monitor-up; }
            Mod+Shift+V { switch-focus-between-floating-and-tiling; }
            Mod+Shift+WheelScrollDown { focus-column-right; }
            Mod+Shift+WheelScrollUp { focus-column-left; }
            Mod+Space hotkey-overlay-title="Run an Application" { spawn "fuzzel"; }
            Mod+U { focus-workspace-down; }
            Mod+Up { focus-window-up; }
            Mod+V { toggle-window-floating; }
            Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
            Mod+WheelScrollLeft { focus-column-left; }
            Mod+WheelScrollRight { focus-column-right; }
            Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
            Mod+W { toggle-column-tabbed-display; }
            Super+Alt+1 hotkey-overlay-title="Screenshot the entire screen" { screenshot-screen; }
            Super+Alt+2 hotkey-overlay-title="Screenshot the current window" { screenshot-window; }
            Super+Alt+3 hotkey-overlay-title="Screenshot" { screenshot; }
            Super+Alt+B hotkey-overlay-title="Switch to random background image" { spawn-sh "nu ${../nushell/scripts/set-wallpaper.nu} next"; }
            Super+Alt+Delete hotkey-overlay-title="Exit niri" { quit; }
            Super+Alt+L hotkey-overlay-title="Lock the Screen" { spawn "hyprlock"; }
            Super+Alt+M hotkey-overlay-title="Power off monitors" { power-off-monitors; }
            Super+Alt+N hotkey-overlay-title="Toggle blue light filter" { spawn-sh "nu ${../sunsetr/sunsetr.nu} toggle"; }
            Super+Alt+Shift+B hotkey-overlay-title="Toggle automatic background image switching" { spawn-sh "nu ${../nushell/scripts/set-wallpaper.nu} toggle-pause"; }
            Super+Alt+S hotkey-overlay-title="Put the computer to sleep" { spawn-sh "niri msg action power-off-monitors; systemctl suspend"; }
            Super+Alt+V hotkey-overlay-title="Switch to random background image" { spawn-sh "nu ${../nushell/scripts/set-wallpaper.nu} previous"; }
            Super+Alt+W hotkey-overlay-title="Restart waybar" { spawn "systemctl" "--user" "restart" "waybar"; }
            XF86AudioLowerVolume allow-when-locked=true { spawn-sh "nu ${../music-player/is-muted.nu} && wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"; }
            XF86AudioMicMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
            XF86AudioMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
            XF86AudioNext allow-when-locked=true { spawn-sh "playerctl next || rmpc next"; }
            XF86AudioPlay allow-when-locked=true { spawn-sh "playerctl play-pause; rmpc togglepause"; }
            XF86AudioPrev allow-when-locked=true { spawn-sh "playerctl previous || rmpc prev"; }
            XF86AudioRaiseVolume allow-when-locked=true {spawn-sh "nu ${../music-player/is-muted.nu} && wpctl set-volume --limit 1.0 @DEFAULT_AUDIO_SINK@ 1%+"; }
            XF86AudioStop allow-when-locked=true { spawn "playerctl" "stop"; }
            XF86LaunchA repeat=false { toggle-overview; }
          ''
          + (
            # TODO: fix spacing
            # TODO: handle all of this with the brightness nushell script
            if config.laptop
            then ''
              Shift+XF86MonBrightnessDown { spawn-sh "brightnessctl --device tpacpi::kbd_backlight set 1%-"; }
              Shift+XF86MonBrightnessUp { spawn-sh "brightnessctl --device tpacpi::kbd_backlight set 1%+"; }
              Super+XF86MonBrightnessDown allow-when-locked=true cooldown-ms=500 hotkey-overlay-title=null { spawn-sh "brightnessctl set 1%";}
              Super+XF86MonBrightnessUp allow-when-locked=true cooldown-ms=500 hotkey-overlay-title=null { spawn-sh "brightnessctl set 100%"; }
              XF86MonBrightnessDown { spawn-sh "brightnessctl set 1%-"; }
              XF86MonBrightnessUp { spawn-sh "brightnessctl set 1%+"; }
            ''
            else ''
              Super+XF86MonBrightnessDown allow-when-locked=true cooldown-ms=500 hotkey-overlay-title=null { spawn-sh "nu ${../monitors/brightness.nu} set min";}
              Super+XF86MonBrightnessUp allow-when-locked=true cooldown-ms=500 hotkey-overlay-title=null { spawn-sh "nu ${../monitors/brightness.nu} set max"; }
              XF86MonBrightnessDown allow-when-locked=true cooldown-ms=500 { spawn-sh "nu ${../monitors/brightness.nu} decrease";}
              XF86MonBrightnessUp allow-when-locked=true cooldown-ms=500 { spawn-sh "nu ${../monitors/brightness.nu} increase"; }
            ''
          );
      in ''
        binds {
            ${binds}
        }

        hotkey-overlay {
            skip-at-startup
        }

        input {
            keyboard {
                xkb {
                    options "${
          builtins.concatStringsSep "," [
            defaultXkbOptions
            cfg.input.keyboard.xkb.options
          ]
        }"
                }

                repeat-delay 200
                repeat-rate 50
            }

            touchpad {
              tap
            }
        }

        layout {
            always-center-single-column

            focus-ring {
                width 1
            }
        }

        prefer-no-csd
        screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
        spawn-at-startup "sunsetr"
        spawn-at-startup "systemctl" "--user" "enable" "wpaperd"
      '';
    };
  };

  imports = [
    ../fuzzel
    ../hypridle
    ../hyprlock
    ../music-player
    ../nautilus
    ../nushell
    ../playerctl
    ../polkit
    ../sunsetr
    ../swaync
    ../wallpaper
    ../waybar
  ];

  options.niri = with types; {
    input.keyboard.xkb.options = mkOption {
      default = defaultXkbOptions;
      type = str;
    };
  };
}
