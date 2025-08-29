{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      brightnessctl
      equibop
      hyprlock
      hyprpicker
      wev
      wl-clipboard
    ];

    pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };
  };

  imports = [
    ../linux/home.nix
    ../../modules/hypr
    ../../modules/rofi
    ../../modules/swaync
    ../../modules/waybar
  ];

  programs.kitty.font.size = 8;
}
