{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    cfg = config.sddm;
  in {
    environment.systemPackages = with pkgs; [
      bibata-cursors

      (catppuccin-sddm.override
        {
          accent = "lavender";
          flavor = "mocha";
          fontSize = "12";
        })
    ];

    services.displayManager = {
      defaultSession = cfg.defaultSession;

      sddm = {
        enable = true;

        settings = {
          AutoLogin.User = config.nixos.username;

          Theme = {
            CursorSize = 16;
            CursorTheme = "Bibata-Modern-Classic";
          };
        };

        theme = "catppuccin-mocha-lavender";
        wayland.enable = true;
      };
    };
  };

  options.sddm.defaultSession = let
    inherit (lib) mkOption types;
  in
    mkOption {
      default = "niri";
      type = types.str;
    };
}
