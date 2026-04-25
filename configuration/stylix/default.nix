{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    theme = name: "${pkgs.base16-schemes}/share/themes/${name}.yaml";
  in {
    specialisation = {
      catppuccin-mocha.configuration.stylix.base16Scheme = theme "catppuccin-mocha";
      default.configuration.stylix.base16Scheme = theme config.stylix.theme;
      gruvbox.configuration.stylix.base16Scheme = theme "gruvbox-dark-medium";
    };

    stylix = {
      base16Scheme = lib.mkDefault (theme config.stylix.theme);
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
