{hostName, ...}: {
  home.file = {
    ".config/hypr/hypridle.conf".source = ./hypridle.conf;
    ".config/hypr/hyprpaper.conf".source = ./hyprpaper.conf;

    ".config/hypr/hyprland.conf".source =
      if hostName == "bumbirich"
      then ./hyprland-bumbirich.conf
      else ./hyprland.conf;

    ".config/hypr/wallpaper".source = ./wallpaper;
  };
}
