{
  config,
  hostName,
  inputs,
  isNixOS,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = let
    cfg = config.nixos;
  in {
    boot = {
      kernelModules = ["i2c-dev"];

      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };

    environment = {
      sessionVariables.NIXOS_OZONE_WL = "1";

      systemPackages = with pkgs; [
        bibata-cursors
        (catppuccin-sddm.override
          {
            accent = "lavender";
            flavor = "mocha";
            font = "Cantarell";
            fontSize = "12";
          })
        firefox
        git
        helix
        xdg-utils
      ];
    };

    hardware = {
      bluetooth.enable = true;
      i2c.enable = true;
    };

    home-manager = {
      extraSpecialArgs = {
        inherit hostName inputs isNixOS;
      };

      useGlobalPkgs = true;

      users.${cfg.username} =
        import ../../systems/nixos/hosts/${hostName}/home.nix;
    };

    i18n = let
      locale = "en_US.UTF-8";
    in {
      defaultLocale = locale;
      # TODO: can this be linked to waybar configuration, which is the only
      # place (so far) that it is used?
      extraLocales = ["en_GB.UTF-8/UTF-8"];

      extraLocaleSettings = {
        LC_ADDRESS = locale;
        LC_IDENTIFICATION = locale;
        LC_MEASUREMENT = locale;
        LC_MONETARY = locale;
        LC_NAME = locale;
        LC_NUMERIC = locale;
        LC_PAPER = locale;
        LC_TELEPHONE = locale;
        LC_TIME = locale;
      };
    };

    networking = {
      inherit hostName;
      networkmanager.enable = true;
    };

    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      settings = {
        experimental-features = ["nix-command" "flakes"];
        trusted-users = ["root" (import ../../modules/users/user.nix).username];
      };
    };

    nixpkgs.config.allowUnfree = true;

    programs = {
      niri.enable = true;
      nix-ld.enable = true;

      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };
    };

    security.rtkit.enable = true;

    services = {
      displayManager = {
        defaultSession = "niri";

        sddm = {
          enable = true;
          package = pkgs.kdePackages.sddm;

          settings = {
            AutoLogin.User = cfg.username;

            Theme = {
              CursorTheme = "Bibata-Modern-Classic";
              CursorSize = 16;
            };
          };

          theme = "catppuccin-mocha-lavender";
          wayland.enable = true;
        };
      };

      fwupd.enable = true;

      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };

      solaar.enable = true;
      udev.extraRules = ''KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"'';
      udisks2.enable = true;
      wayland-pipewire-idle-inhibit.enable = true;
    };

    stylix = {
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      enable = true;
      polarity = "dark";
    };

    system.stateVersion = "23.11";
    time.timeZone = "America/New_York";

    users.users.${cfg.username} = {
      description = cfg.name;
      extraGroups = ["i2c" "networkmanager" "wheel"];
      isNormalUser = true;
      shell = pkgs.nushell;
    };
  };

  imports = [
    inputs.home-manager.nixosModules.home-manager
    # TODO: pull out into a nixos modules folder?
    ../../modules/dropbox
  ];

  options.nixos = with types; let
    user = import ../../modules/users/user.nix;
  in {
    name = mkOption {
      default = user.name;
      type = str;
    };

    username = mkOption {
      default = user.username;
      type = str;
    };
  };
}
