{pkgs, ...}: {
  home = {
    file = {
      ".config/waybar/colors.css".source = ./colors.css;
      ".config/waybar/config.jsonc".source = ./config.jsonc;
      ".config/waybar/style.css".source = ./style.css;
    };

    packages = [pkgs.waybar];
  };
}
