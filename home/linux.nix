{ pkgs, ... }:

{
  home = {
    homeDirectory = "/home/benrosen";

    packages = with pkgs; [
      mako
      rofi-wayland
    ];
  };
}
