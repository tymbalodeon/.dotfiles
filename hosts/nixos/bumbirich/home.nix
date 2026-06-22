{
  imports = [
    ../../../modules/home-manager
    ../../../modules/home-manager/niri
    ../../../modules/home-manager/wallpaper
  ];

  laptop = true;
  niri.input.keyboard.xkb.options = "altwin:swap_lalt_lwin";
  wallpaper.padSize = 37;
}
