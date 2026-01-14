{
  config,
  hostName,
  hostType,
  inputs,
  lib,
  pkgs,
  pkgs-stable,
  ...
}: {
  config = let
    username = config.darwin.username;
  in {
    home-manager = {
      extraSpecialArgs = {inherit hostType inputs pkgs-stable;};
      users.${username} = import ../hosts/${hostType}/${hostName}/home.nix;
    };

    nix.enable = false;

    nixpkgs.overlays = [
      (final: prev:
        with pkgs-stable; {
          inherit
            ktty
            mpd
            nix-search-cli
            uutils-coreutils-no-prefix
            ;
        })
    ];

    security.sudo.extraConfig = ''Defaults env_keep += "TERM TERMINFO"'';

    stylix = {
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      enable = true;
      polarity = "dark";
    };

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

      primaryUser = username;
      stateVersion = 6;
    };

    users.users.${username}.home = /Users/${username};
  };

  imports = [inputs.home-manager.darwinModules.home-manager];

  options.darwin.username = let
    user = import ../users;
  in
    with lib;
      mkOption {
        default = user.username;
        type = types.str;
      };
}
