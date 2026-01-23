{
  channel,
  config,
  home-manager,
  hostName,
  hostType,
  lib,
  pkgs-master,
  ...
}: {
  config = let
    cfg = config.darwin;
  in {
    home-manager = {
      extraSpecialArgs = {
        inherit
          channel
          hostType
          pkgs-master
          ;
      };

      users.${cfg.username} = import cfg.homeFile;
    };

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

  imports = [
    home-manager.darwinModules.home-manager

    ./stylix
  ];

  options.darwin = let
    inherit (lib) mkOption types;

    user = import ../users;
  in
    with types; {
      homeFile = mkOption {
        default = ../hosts/${hostType}/${channel}/${hostName}/home.nix;
        type = path;
      };

      username = mkOption {
        default = user.username;
        type = str;
      };
    };
}
