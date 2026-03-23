{
  config,
  lib,
  pkgs,
  ...
}: {
  config.stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${config.stylix.theme}.yaml";
    enable = true;
    polarity = "dark";
  };

  options.stylix.theme = lib.mkOption {
    default = let
      themeOverride = builtins.getEnv "STYLIX_THEME";

      theme =
        if themeOverride == ""
        then "catppuccin-mocha"
        else themeOverride;
    in
      theme;
    type = lib.types.str;
  };
}
