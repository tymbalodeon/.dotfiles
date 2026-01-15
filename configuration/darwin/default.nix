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
    username = config.darwin.username;
  in {
    home-manager = {
      extraSpecialArgs = {inherit hostType pkgs-25_05;};

      users.${username} =
        import ../hosts/${hostType}/${channel}/${hostName}/home.nix;
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

      primaryUser = username;
      stateVersion = 6;
    };

    users.users.${username}.home = /Users/${username};
  };

  imports = [home-manager.darwinModules.home-manager];

  options.darwin.username = let
    user = import ../users;
  in
    with lib;
      mkOption {
        default = user.username;
        type = types.str;
      };
}
