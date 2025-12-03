{
  home.file."wallpaper/wallpaper.jpeg".source = ../../wallpaper.jpeg;

  services.wpaperd = {
    enable = true;

    settings.default = {
      duration = "15m";
      path = "~/wallpaper";
    };
  };
}
