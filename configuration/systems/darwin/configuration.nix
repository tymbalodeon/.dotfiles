{
  config,
  hostName,
  inputs,
  isNixOS,
  lib,
  ...
}:
with lib; let
  cfg = config.darwin;
in {
  config = {
    home-manager = {
      extraSpecialArgs = {inherit inputs isNixOS;};

      users.${cfg.username} =
        import ../../systems/darwin/hosts/${hostName}/home.nix;
    };

    imports = [inputs.home-manager.darwinModules.home-manager];
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
        NSGlobalDomain._HIHideMenuBar = true;
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

  options.darwin = with types; let
    user = import ../../modules/users/user.nix;
  in {
    username = mkOption {
      default = user.username;
      type = str;
    };
  };
}
