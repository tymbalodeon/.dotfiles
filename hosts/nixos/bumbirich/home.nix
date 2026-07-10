{
  imports = [
    ../../../modules/home-manager
    ../../../modules/home-manager/wallpaper
    ../../../modules/home-manager/window-manager
  ];

  laptop = true;
  niri.input.keyboard.xkb.options = "altwin:swap_lalt_lwin";
  wallpaper.padSize = 37;
}
