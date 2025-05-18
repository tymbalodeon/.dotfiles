# TODO: address this error:
# - The `system.activationScripts.postUserActivation` option has
#   been removed, as all activation now takes place as `root`. Please
#   restructure your custom activation scripts appropriately,
#   potentially using `sudo` if you need to run commands as a user.
#
#   - Previously, some nix-darwin options applied to the user running
#   `darwin-rebuild`. As part of a long‐term migration to make
#   nix-darwin focus on system‐wide activation and support first‐class
#   multi‐user setups, all system activation now runs as `root`, and
#   these options instead apply to the `system.primaryUser` user.
#
#   You currently have the following primary‐user‐requiring options set:
#   * `system.defaults.NSGlobalDomain._HIHideMenuBar`
#   * `system.defaults.controlcenter.Bluetooth`
#   * `system.defaults.controlcenter.FocusModes`
#   * `system.defaults.controlcenter.Sound`
#   * `system.defaults.dock.autohide`
#   * `system.defaults.dock.mineffect`
#   * `system.defaults.menuExtraClock.IsAnalog`
#   To continue using these options, set `system.primaryUser` to the name
#
#   of the user you have been using to run `darwin-rebuild`. In the long
#   run, this setting will be deprecated and removed after all the
#   functionality it is relevant for has been adjusted to allow
#   specifying the relevant user separately, moved under the
#   `users.users.*` namespace, or migrated to Home Manager.
#
#   If you run into any unexpected issues with the migration, please
#   open an issue at <https://github.com/nix-darwin/nix-darwin/issues/new>
#   and include as much information as possible.
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

  users.users = let
    defaultUser = import ../../modules/users/default-user.nix;
  in {
    ${defaultUser.username}.home = defaultUser.homeDirectoryDarwin;
  };
}
