{
  config,
  hostName,
  inputs,
  isNixOS,
  lib,
  pkgs,
  pkgs-stable,
  ...
}:
with lib; {
  config = let
    cfg = config.darwin;
  in {
    home-manager = {
      extraSpecialArgs = {inherit inputs isNixOS;};

      users.${cfg.username} =
        import ../../systems/darwin/hosts/${hostName}/home.nix;
    };

    nix.enable = false;

    nixpkgs.overlays = [
      (final: prev: {
        kitty = pkgs-stable.kitty;
        mpd = pkgs-stable.mpd;
        nix-search-cli = pkgs-stable.nix-search-cli;
        uutils-coreutils-noprefix = pkgs-stable.uutils-coreutils-noprefix;
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

      primaryUser = cfg.username;
      stateVersion = 6;
    };

    users.users.${cfg.username}.home = /Users/${cfg.username};
  };

  imports = [inputs.home-manager.darwinModules.home-manager];

  options.darwin = with types; let
    user = import ../../modules/users/user.nix;
  in {
    username = mkOption {
      default = user.username;
      type = str;
    };
  };
}
