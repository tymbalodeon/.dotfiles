{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    stylix = {
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${config.stylix.theme}.yaml";
      enable = true;
      polarity = "dark";
    };

    specialisation = let
      theme = name: lib.mkForce "${pkgs.base16-schemes}/share/themes/${name}.yaml";
    in {
      catppuccin-mocha.configuration.stylix.base16Scheme = theme "catppuccin-mocha";
      default.configuration.stylix.base16Scheme = theme config.stylix.theme;
      gruvbox.configuration.stylix.base16Scheme = theme "gruvbox-dark";
      tarot.configuration.stylix.base16Scheme = theme "tarot";
    };
  };

  options.stylix.theme = lib.mkOption {
    default = let
      themeOverride = builtins.getEnv "STYLIX_THEME";
    in
      if themeOverride == ""
      then "catppuccin-mocha"
      else themeOverride;

    type = lib.types.str;
  };
}
