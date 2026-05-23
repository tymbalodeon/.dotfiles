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
        file
        imagemagick
        swaybg
      ];
    };

    nushell.extraScripts = let
      colors = config.lib.stylix.colors.withHashtag;
    in [
      {
        includes = ["storage"];
        name = "wallpaper";

        text =
          ''
            def default-wallpaper [] {
              "${./default-wallpaper.jpeg}"
            }

            # TODO: move this to the stylix module!
            def base16-colors [] {
              {
                base00: "${colors.base00}"
                base01: "${colors.base01}"
                base02: "${colors.base02}"
                base03: "${colors.base03}"
                base04: "${colors.base04}"
                base05: "${colors.base05}"
                base06: "${colors.base06}"
                base07: "${colors.base07}"
                base08: "${colors.base08}"
                base09: "${colors.base09}"
                base0A: "${colors.base0A}"
                base0B: "${colors.base0B}"
                base0C: "${colors.base0C}"
                base0D: "${colors.base0D}"
                base0E: "${colors.base0E}"
                base0F: "${colors.base0F}"
              }
            }

            def waybar-height [] {
              ${toString cfg.padSize}
            }
          ''
          + "\n"
          + builtins.readFile ./wallpaper.nu;
      }
    ];

    programs.parallel.enable = true;

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
