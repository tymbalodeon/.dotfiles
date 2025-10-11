{
  config,
  hostName,
  inputs,
  isNixOS,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixos;
in {
  config = {
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
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
        hyprpaper
        xdg-utils
      ];
    };

    hardware.bluetooth.enable = true;

    home-manager = {
      extraSpecialArgs = {
        inherit hostName inputs isNixOS;
      };

      useGlobalPkgs = true;

      users.${cfg.username} =
        import ../../systems/nixos/hosts/${hostName}/home.nix;
    };

    i18n = {
      defaultLocale = "en_US.UTF-8";

      extraLocaleSettings = let
        locale = "en_US.UTF-8";
      in {
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

      settings.experimental-features = ["nix-command" "flakes"];
    };

    nixpkgs.config.allowUnfree = true;

    programs = {
      hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };

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
        defaultSession = "hyprland-uwsm";

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

      hypridle.enable = true;

      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };

      solaar.enable = true;
      udisks2.enable = true;
    };

    system.stateVersion = "23.11";
    time.timeZone = "America/New_York";

    users.users.${cfg.username} = {
      description = cfg.name;
      extraGroups = ["networkmanager" "wheel"];
      isNormalUser = true;
      shell = pkgs.nushell;
    };
  };

  imports = [inputs.home-manager.nixosModules.home-manager];

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
