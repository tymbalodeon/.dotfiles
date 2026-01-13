{
  imports = [
    ../../../home-manager/home-nixos.nix
    ../../../home-manager/niri
  ];

  laptop = true;
  niri.input.keyboard.xkb.options = "altwin:swap_alt_win";

  # TODO: is this still needed anywhere?
  # monitor = "Chimei Innolux Corporation 0x14C9, preferred, auto, 1";
}
