{
  config,
  lib,
  pkgs,
  ...
}: {
  config.stylix = with pkgs; {
    base16Scheme = "${base16-schemes}/share/themes/${config.stylix.theme}.yaml";

    cursor = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 16;
    };

    enable = true;

    fonts = {
      monospace = {
        name = "Iosevka";
        package = iosevka;
      };

      sansSerif = {
        name = "IBM Plex Sans";
        package = google-fonts;
      };

      serif = {
        name = "Gentium Book";
        package = gentium-book;
      };

      sizes.applications = 9;
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
