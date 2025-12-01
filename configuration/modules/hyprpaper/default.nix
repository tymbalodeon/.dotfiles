{
  services.hyprpaper = {
    enable = true;

    settings = let
      wallpaper = "${./hildegard.jpeg}";
    in {
      preload = "${wallpaper}";
      wallpaper = [", ${wallpaper}"];
    };
  };
}
