{
  inputs,
  pkgs,
  ...
}: {
  home = {
    file = {
      ".config/rofi/catppuccin-mocha.rasi".source = "${
        inputs.rofi-theme
      }/themes/catppuccin-mocha.rasi";

      ".config/rofi/config.rasi".text =
        "@import \"catppuccin-mocha\"\n"
        + (builtins.readFile "${
          inputs.rofi-theme
        }/catppuccin-default.rasi");
    };

    packages = [pkgs.rofi];
  };
}
