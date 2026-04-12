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

      file."wallpaper/default-wallpaper.jpeg".source = ./default-wallpaper.jpeg;

      packages = with pkgs; [
        imagemagick
        swaybg
      ];
    };

    nushell.extraScripts = [
      {
        includes = ["storage"];
        name = "wallpaper";

        text =
          ''
            def default-wallpaper [] {
              "${./default-wallpaper.jpeg}"
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
        mode = "fit";
        path = "~/wallpaper";
      };
    };
  };

  imports = [
    ../fzf
    ../nushell
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
