{
  imports = [../../../home-manager];

  niri = {
    input.keyboard.xkb.options = "altwin:swap_alt_win";
    laptop = true;
  };

  waybar.laptop = true;
}
