{
  imports = [
    ../../../../home-manager
    ../../../../home-manager/hyprland
    ../../../../home-manager/kitty
    ../../../../home-manager/wallpaper
  ];

  kitty.fontSize = 12.0;
  laptop = true;
  niri.input.keyboard.xkb.options = "altwin:swap_alt_win";
  wallpaper.padSize = 37;
}
