{
  inputs,
  isNixOS,
  ...
}: {
  home-manager.extraSpecialArgs = {inherit inputs isNixOS;};
  imports = [inputs.home-manager.darwinModules.home-manager];

  nix.enable = false;
  security.sudo.extraConfig = ''Defaults env_keep += "TERM TERMINFO"'';

  system = {
    activationScripts.postUserActivation.text = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

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

    stateVersion = 6;
  };

  users.users.benrosen.home = /Users/benrosen;
}
