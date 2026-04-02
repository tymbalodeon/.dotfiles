{pkgs, ...}: let
  wallpaper = ./wallpaper.jpeg;
in {
  home.packages = with pkgs; [
    imagemagick
    swaybg
  ];

  imports = [
    ../fzf
    ../nushell
  ];

  nushell.extraScripts = [
    (pkgs.writeText "wallpaper-clear.nu" ''
      #!/usr/bin/env nu

      use ${./wallpaper.nu} wallpaper-directory

      # Clear the wallpaper folder
      def "wallpaper clear" [] {
        let wallpaper_directory = (wallpaper-directory)

        rm --force --recursive $wallpaper_directory
        mkdir $wallpaper_directory
        cp ${wallpaper} $wallpaper_directory
      }
    '')

    ./wallpaper.nu
  ];

  services = {
    wpaperd = {
      enable = true;

      settings.default = {
        duration = "15m";
        exec = ./signal-waybar.sh;
        mode = "fit";
        path = "~/wallpaper";
      };
    };
  };
}
