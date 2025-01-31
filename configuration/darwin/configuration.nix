{inputs, ...}: {
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users.benrosen = import ./home.nix;
  };

  imports = [inputs.home-manager.darwinModules.home-manager];
  users.users.benrosen.home = "/Users/benrosen";

  system = {
    activationScripts.postUserActivation.text = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
      controlcenter = {
        Bluetooth = true;
        FocusModes = true;
        NowPlaying = true;
        Sound = true;
      };

      dock = {
        autohide = true;
        mineffect = "scale";
      };

      NSGlobalDomain._HIHideMenuBar = true;
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    stateVersion = 6;
  };
}
