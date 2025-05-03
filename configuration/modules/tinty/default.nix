{
  isNixOS,
  lib,
  pkgs,
  ...
}: {
  home = {
    file =
      {
        ".config/tinty/fzf.toml".source =
          if pkgs.stdenv.isDarwin
          then ./fzf-darwin.toml
          else ./fzf-linux.toml;

        ".config/tinty/helix.toml".source = ./helix.toml;
        ".config/tinty/kitty.toml".source = ./kitty.toml;
        ".config/tinty/shell.toml".source = ./shell.toml;
      }
      // lib.optionalAttrs isNixOS {
        ".config/tinty/rofi.toml".source = ./rofi.toml;
        ".config/tinty/waybar.toml".source = ./waybar.toml;
      };

    packages = [pkgs.tinty];
  };
}
