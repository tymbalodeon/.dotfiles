{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    cfg = config.displayManager;
    colors = config.lib.stylix.colors.withHashtag;

    sddm-astronaut = pkgs.sddm-astronaut.override {
      themeConfig = {
        BackgroundColor = colors.base00;
        DateFormat = "dddd MMMM d yyyy";
        DateTextColor = colors.base05;
        DimBackground = 1.0;
        DimBackgroundColor = colors.base00;
        DropdownBackgroundColor = colors.base00;
        DropdownSelectedBackgroundColor = colors.base01;
        DropdownTextColor = colors.base05;
        Font = config.stylix.fonts.sansSerif.name;
        FontSize = config.stylix.fonts.sizes.desktop;
        FormBackgroundColor = colors.base00;
        HaveFormBackground = true;
        HeaderTextColor = colors.base05;
        HideVirtualKeyboard = true;
        HighlightBackgroundColor = colors.base03;
        HighlightBorderColor = colors.base03;
        HighlightTextColor = colors.base05;
        HourFormat = "h:mm AP";
        HoverPasswordIconColor = colors.base07;
        HoverSessionButtonTextColor = colors.base07;
        HoverSystemButtonsIconsColor = colors.base07;
        HoverUserIconColor = colors.base07;
        HoverVirtualKeyboardButtonTextColor = colors.base07;
        LoginButtonBackgroundColor = colors.base01;
        LoginButtonTextColor = colors.base05;
        LoginFieldBackgroundColor = colors.base02;
        LoginFieldTextColor = colors.base05;
        PartialBlur = false;
        PasswordFieldBackgroundColor = colors.base02;
        PasswordFieldTextColor = colors.base05;
        PasswordIconColor = colors.base05;
        PlaceholderTextColor = colors.base03;
        SessionButtonTextColor = colors.base05;
        SystemButtonsIconsColor = colors.base05;
        TimeTextColor = colors.base05;
        UseRealName = false;
        UserIconColor = colors.base05;
        VirtualKeyboardButtonTextColor = colors.base05;
        WarningColor = colors.base0A;
      };
    };
  in {
    environment.systemPackages = with pkgs; [
      bibata-cursors
      sddm-astronaut
    ];

    services.displayManager = let
      inherit (config.stylix) cursor;
    in {
      inherit (cfg) defaultSession;

      sddm = {
        enable = true;
        extraPackages = [sddm-astronaut];

        settings = {
          AutoLogin.User = config.nixos.username;

          Theme = {
            CursorSize = cursor.size;
            CursorTheme = cursor.name;
          };
        };

        theme = "sddm-astronaut-theme";
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
