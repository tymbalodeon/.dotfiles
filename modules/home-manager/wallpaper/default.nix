{
  config,
  pkgs,
  ...
}: {
  home = {
    packages = with pkgs; [
      file
      imagemagick
    ];
  };

  imports = [
    ../file-manager/yazi
    ../fzf
    ../shell/nushell
    ../storage
  ];

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
            "110"
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
}
