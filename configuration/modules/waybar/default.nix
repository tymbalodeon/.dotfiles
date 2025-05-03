{pkgs, ...}: {
  home.file = {
    ".config/waybar/colors.css".source = ./waybar/colors.css;
    ".config/waybar/config.jsonc".source = ./waybar/config.jsonc;
    ".config/waybar/style.css".source = ./waybar/style.css;

    packages = [pkgs.waybar];
  };
}
