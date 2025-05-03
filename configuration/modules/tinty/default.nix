{
  config,
  lib,
  pkgs,
  ...
}: {
  options.isNixOS = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = "Whether or not the current host is running NixOS";
  };

  config = {
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
        // lib.optionalAttrs config.isNixOS {
          ".config/tinty/rofi.toml".source = ./rofi.toml;
          ".config/tinty/waybar.toml".source = ./waybar.toml;
        };

      packages = [pkgs.tinty];
    };
  };
}
