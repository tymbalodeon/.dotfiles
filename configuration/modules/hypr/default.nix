{config, ...}: {
  home.file = {
    ".config/hypr/hyprpaper.conf".source = ./hyprpaper.conf;

    ".config/hypr/hyprland.conf".source =
      if config.networking.hostName == "bumbirich"
      then ./hyprland-bumbirich.conf
      else ./hyprland.conf.conf;

    ".config/hypr/wallpaper".source = ./wallpaper;
  };
}
