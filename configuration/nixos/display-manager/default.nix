{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    cfg = config.displayManager;
  in {
    environment.systemPackages = with pkgs; [
      bibata-cursors

      (catppuccin-sddm.override
        {
          accent = "lavender";
          background = ../../home-manager/wallpaper/default-wallpaper.jpeg;
          clockEnabled = false;
          flavor = "mocha";
          font = config.stylix.fonts.sansSerif.name;
          fontSize = "11";
          loginBackground = true;
        })
    ];

    services.displayManager = let
      cursorSize = 24;
      cursorTheme = "Bibata-Modern-Classic";
    in {
      inherit (cfg) defaultSession;

      sddm = {
        enable = true;

        settings = {
          AutoLogin.User = config.nixos.username;

          Theme = {
            CursorSize = cursorSize;
            CursorTheme = cursorTheme;
          };
        };

        setupScript = "export XCURSOR_THEME=${cursorTheme}";
        theme = "catppuccin-mocha-lavender";
        wayland.enable = true;
      };
    };
  };

  options.displayManager.defaultSession = let
    inherit (lib) mkOption types;
  in
    mkOption {
      default = "niri";
      type = types.str;
    };
}
