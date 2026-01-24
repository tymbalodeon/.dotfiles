{pkgs}: let
  themeOverride = builtins.getEnv "STYLIX_THEME";

  theme =
    if themeOverride == ""
    then "catppuccin-mocha"
    else themeOverride;
in {
  base16Scheme = "${pkgs.base16-schemes}/share/themes/${theme}.yaml";
  enable = true;
  polarity = "dark";
}
