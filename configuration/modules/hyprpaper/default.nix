{
  services.hyprpaper.settings = let
    wallpaper = "${../../wallpaper.jpeg}";
  in {
    preload = "${wallpaper}";
    wallpaper = [", ${wallpaper}"];
  };
}
