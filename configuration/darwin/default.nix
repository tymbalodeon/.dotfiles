{
  channel,
  config,
  home-manager,
  hostName,
  hostType,
  lib,
  pkgs,
  pkgs-25_05,
  ...
}: {
  config = let
    cfg = config.darwin;
  in {
    home-manager = {
      extraSpecialArgs = {inherit channel hostType pkgs-25_05;};
      users.${cfg.username} = cfg.home;
    };

    nix.enable = false;

    nixpkgs.overlays = [
      (final: prev:
        with pkgs-25_05; {
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

      primaryUser = cfg.username;
      stateVersion = 6;
    };

    users.users.${cfg.username}.home = /Users/${cfg.username};
  };

  imports = [home-manager.darwinModules.home-manager];

  options.darwin = let
    inherit (lib) mkOption types;

    user = import ../users;
  in
    with types; {
      home = mkOption {
        default = import ../hosts/${hostType}/${channel}/${hostName}/home.nix;
        type = attrs;
      };

      username = mkOption {
        default = user.username;
        type = str;
      };
    };
}
