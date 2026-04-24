{
  config,
  lib,
  pkgs,
  ...
}: {
  config.stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${config.stylix.theme}.yaml";
    enable = true;

    fonts = {
      monospace = {
        name = "JetBrainsMono Nerd Font Mono";
        package = pkgs.nerd-fonts.jetbrains-mono;
      };

      sansSerif = {
        name = "IBM Plex Sans";
        package = pkgs.ibm-plex;
      };
    };

    polarity = "dark";
  };

  options.stylix.theme = lib.mkOption {
    default = let
      themeOverride = builtins.getEnv "DOTFILES_STYLIX_THEME";

      theme =
        if themeOverride == ""
        then "catppuccin-mocha"
        else themeOverride;
    in
      theme;
    type = lib.types.str;
  };
}
