{
  config,
  lib,
  pkgs,
  ...
}: {
  config.stylix = with pkgs; {
    base16Scheme = "${base16-schemes}/share/themes/${config.stylix.theme}.yaml";
    enable = true;

    fonts = {
      monospace = {
        name = "Iosevka";
        package = iosevka;
      };

      sansSerif = {
        name = "Adwaita Sans";
        package = adwaita-fonts;
      };

      serif = {
        name = "TeX Gyre Termes";
        package = tex-gyre.termes;
      };
    };

    polarity = "dark";
  };

  options.stylix.theme = lib.mkOption {
    default = let
      themeOverride = builtins.getEnv "DOTFILES_STYLIX_THEME";

      theme =
        if themeOverride == ""
        then "caroline"
        else themeOverride;
    in
      theme;
    type = lib.types.str;
  };
}
