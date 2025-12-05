{
  imports = [
    ../../home.nix
    ../../../../modules/niri
  ];

  # TODO:port these extra laptop settings over to niri
  # "SHIFT, XF86MonBrightnessDown, exec, brightnessctl --device tpacpi::kbd_backlight set 1%-"
  # "SHIFT, XF86MonBrightnessUp, exec, brightnessctl --device tpacpi::kbd_backlight set 1%+"
  # ", XF86MonBrightnessDown, exec, brightnessctl set 1%- && notify-send \"Brightness: $(brightnessctl | rg '\d*%' --only-matching)\""
  # ", XF86MonBrightnessUp, exec, brightnessctl set 1%+ && notify-send \"Brightness: $(brightnessctl | rg '\d*%' --only-matching)\""

  # input.kb_options = "caps:escape,altwin:swap_alt_win";
  # monitor = "Chimei Innolux Corporation 0x14C9, preferred, auto, 1";
}
