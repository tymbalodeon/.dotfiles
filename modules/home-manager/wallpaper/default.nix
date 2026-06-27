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
      activation.wallpaper = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir --parents ~/wallpaper
      '';

      file."wallpaper/default-wallpaper.jpg".source = ./default-wallpaper.jpg;

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
            def default-wallpaper [] {
              "${./default-wallpaper.jpg}"
            }

            def waybar-height [] {
              ${toString cfg.padSize}
            }
          ''
          + "\n"
          + builtins.readFile ./wallpaper.nu;
      }
    ];

    services.wpaperd = {
      enable = true;

      settings.default = {
        duration = "15m";
        exec = ./signal-waybar.sh;
        mode = "fit-border-color";
        path = "~/wallpaper";
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
