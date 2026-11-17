{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.theme;
in {
  config.stylix = with pkgs; {
    base16Scheme = "${base16-schemes}/share/themes/${config.theme.name}.yaml";

    cursor = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 16;
    };

    enable = true;

    fonts = {
      monospace = cfg.fonts.monospace;
      sansSerif = cfg.fonts.sansSerif;
      serif = cfg.fonts.serif;
      sizes = cfg.fonts.sizes;
    };

    polarity = "dark";
  };

  options.theme = let
    inherit (lib) mkOption types;
    inherit (types) str;

    getEnv = key: builtins.getEnv "DOTFILES_THEME_${lib.toUpper key}";

    getFont = key: default: let
      font = getEnv key;
    in
      if font == ""
      then default
      else font;
  in {
    fonts = let
      inherit (lib.types) int submodule;

      fontType = submodule {
        options = {
          name = mkOption {
            type = str;
          };

          package = mkOption {
            type = types.package;
          };
        };
      };

      package = pkgs.google-fonts;
    in
      mkOption {
        type = submodule {
          options = {
            monospace = mkOption {
              default = {
                inherit package;

                name = getFont "monospace_font" "Atkinson Hyperlegible Mono";
              };

              type = fontType;
            };

            sansSerif = mkOption {
              default = {
                inherit package;

                name = getFont "sans_serif_font" "Atkinson Hyperlegible Next";
              };

              type = fontType;
            };

            serif = mkOption {
              default = {
                name = getFont "serif_font" "Gentium Book";
                package = pkgs.gentium-book;
              };

              type = fontType;
            };

            sizes = mkOption {
              type = submodule {
                options = let
                  defaultSize = 10;
                in {
                  applications = mkOption {
                    default = defaultSize;
                    type = int;
                  };

                  desktop = mkOption {
                    default = defaultSize;
                    type = int;
                  };
                };
              };
            };
          };
        };
      };

    name = mkOption {
      default = let
        themeOverride = getEnv "name";
      in
        if themeOverride == ""
        then "caroline"
        else themeOverride;

      type = str;
    };
  };
}
