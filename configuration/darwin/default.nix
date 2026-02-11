{
  config,
  lib,
  ...
}: {
  config = let
    cfg = config.darwin;
  in {
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
        };

        menuExtraClock.IsAnalog = false;

        NSGlobalDomain = {
          "com.apple.swipescrolldirection" = false;
          InitialKeyRepeat = 15;
          KeyRepeat = 2;
          _HIHideMenuBar = true;
        };

        SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      };

      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };

      primaryUser = cfg.username;
      stateVersion = 6;
    };

    users.users.${cfg.username}.home = /Users/${cfg.username};
  };

  imports = [
    ./home-manager
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
