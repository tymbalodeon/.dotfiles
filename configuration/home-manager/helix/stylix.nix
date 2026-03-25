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
        themes.stylix-modified = let
          stylixTheme = fromTOML (
            builtins.readFile "${base16-helix}/base16-${config.stylix.theme}.toml"
          );
        in
          stylixTheme
          // {
            "markup.heading.marker" = "";
            "markup.heading.1" = "base09";
            "markup.heading.2" = "base0A";
            "markup.heading.3" = "base0B";
            "markup.heading.4" = "base0C";
            "markup.heading.5" = "base0D";
            "markup.heading.6" = "base0E";

            "ui.cursor.primary" = {
              bg = "base0E";
              fg = "base01";
            };

            "ui.gutter.selected" = {bg = "base01";};
            "ui.virtual.indent-guide" = "base01";
            "ui.virtual.whitespace" = "base01";
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
