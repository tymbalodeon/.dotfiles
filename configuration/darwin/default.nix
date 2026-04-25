{
  config,
  hostName,
  lib,
  ...
}: {
  config = let
    cfg = config.darwin;
  in {
    networking.hostName = hostName;
    nix.enable = false;
    security.sudo.extraConfig = ''Defaults env_keep += "TERM TERMINFO"'';

    system = {
      defaults = {
        controlcenter = {
          Bluetooth = true;
          FocusModes = true;
          Sound = true;
        };

        dock = {
          autohide = true;
          mineffect = "scale";
          show-recents = false;
        };

        finder = {
          AppleShowAllExtensions = true;
          FXEnableExtensionChangeWarning = false;
          FXPreferredViewStyle = "Nlsv";
          NewWindowTarget = "Other";
          NewWindowTargetPath = "file:///Users/${cfg.username}";
          ShowStatusBar = true;
        };

        iCal."first day of week" = "Monday";
        loginwindow.autoLoginUser = cfg.username;

        NSGlobalDomain = {
          "com.apple.swipescrolldirection" = false;
          InitialKeyRepeat = 15;
          KeyRepeat = 2;
          _HIHideMenuBar = true;
        };

        screensaver.askForPassword = false;
        SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

        trackpad = {
          Clicking = true;
          TrackpadRightClick = true;
        };
      };

      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };

      primaryUser = cfg.username;
      startup.chime = false;
      stateVersion = 6;
    };

    users.users.${cfg.username}.home = /Users/${cfg.username};
  };

  imports = [
    # ./home-manager
    ./stylix
  ];

  options.darwin = let
    user = import ../users;
  in
    with lib; {
      username = mkOption {
        default = user.username;
        type = types.str;
      };
    };
}
