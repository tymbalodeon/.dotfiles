{
  base16-helix,
  config,
  lib,
  ...
}: {
  config = let
    cfg = config.helix;
  in {
    programs.helix =
      {
        themes =
          builtins.foldl'
          (a: b: a // b)
          {}
          (map
            (filename: let
              name =
                builtins.replaceStrings [".toml"] [""] filename;
            in {"${name}" = fromTOML (builtins.readFile "${base16-helix}/${filename}");})
            (builtins.attrNames (builtins.readDir base16-helix)))
          // {
            stylix-modified =
              fromTOML (
                builtins.readFile
                "${base16-helix}/base16-${config.stylix.theme}.toml"
              )
              // {
                "markup.heading.1" = "base09";
                "markup.heading.2" = "base0A";
                "markup.heading.3" = "base0B";
                "markup.heading.4" = "base0C";
                "markup.heading.5" = "base0D";
                "markup.heading.6" = "base0E";
                "markup.heading.marker" = "";

                "ui.cursor.primary" = {
                  bg = "base0E";
                  fg = "base01";
                };

                "ui.bufferline" = {
                  bg = "base00";
                  fg = "base04";
                };

                "ui.bufferline.active" = {
                  bg = "base00";
                  fg = "base06";

                  underline = {
                    color = "base06";
                    style = "line";
                  };
                };

                "ui.bufferline.background" = {bg = "base00";};
                "ui.gutter.selected" = {bg = "base01";};
                "ui.virtual.indent-guide" = "base01";
                "ui.virtual.whitespace" = "base01";
              };
          };
      }
      // lib.optionalAttrs (
        cfg.stylix.enable
        && !cfg.useDefaultStylixTheme
      ) {
        settings.theme = "stylix-modified";
      };

    stylix.targets.helix.enable =
      cfg.stylix.enable && cfg.useDefaultStylixTheme;
  };

  imports = [../../stylix];

  options.helix = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    stylix.enable = mkOption {
      default = true;
      type = types.bool;
    };

    useDefaultStylixTheme =
      mkEnableOption "Use the default stylix theme, if using stylix";
  };
}
