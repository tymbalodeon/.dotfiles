{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    cfg = config.wallpaper;
  in {
    home = {
      packages = with pkgs; [
        file
        imagemagick
      ];
    };

    nushell.extraScripts = [
      {
        includes = [
          "storage"
          "theme"
        ];

        name = "wallpaper";

        text =
          ''
            def waybar-height [] {
              ${toString cfg.padSize}
            }
          ''
          + "\n"
          + builtins.readFile ./wallpaper.nu;
      }
    ];

    services.wpaperd = let
      wallpaperDirectory = "${config.home.homeDirectory}/wallpaper";
    in {
      enable =
        builtins.pathExists wallpaperDirectory
        && builtins.readDir wallpaperDirectory != [];

      settings.default = {
        duration = "15m";
        exec = ./signal-waybar.sh;
        mode = "fit-border-color";
        path = wallpaperDirectory;
      };
    };
  };

  imports = [
    ../fzf
    ../shell/nushell
    ../storage
    ../yazi
  ];

  options.wallpaper.padSize = let
    inherit (lib) mkOption types;
  in
    mkOption {
      type = types.int;
      default = 55;
    };
}
