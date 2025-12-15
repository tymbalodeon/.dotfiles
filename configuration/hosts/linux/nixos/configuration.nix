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
    boot.loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };

    environment.systemPackages = with pkgs; [
      bibata-cursors
      brave
      (catppuccin-sddm.override
        {
          accent = "lavender";
          flavor = "mocha";
          fontSize = "12";
        })
      git
      helix
      xdg-utils
    ];

    home-manager = {
      extraSpecialArgs = {
        inherit hostName inputs isNixOS;
      };

      useGlobalPkgs = true;
      users.${cfg.username} = import ./${hostName}/home.nix;
    };

    i18n = let
      locale = "en_US.UTF-8";
    in {
      defaultLocale = locale;

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
        trusted-users = [
          "root"
          (import ../../../home-manager/users/user.nix).username
        ];
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

          settings = {
            AutoLogin.User = cfg.username;

            Theme = {
              CursorSize = 16;
              CursorTheme = "Bibata-Modern-Classic";
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

      extraGroups = [
        "networkmanager"
        "wheel"
      ];

      isNormalUser = true;
      shell = pkgs.nushell;
    };
  };

  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../../nixos
  ];

  options.nixos = with types; let
    user = import ../../../home-manager/users/user.nix;
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
