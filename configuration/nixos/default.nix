{
  channel,
  config,
  home-manager,
  hostName,
  hostType,
  lib,
  pkgs,
  pkgs-25_05,
  pkgs-25_11,
  ...
}: {
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
      git
      helix
      xdg-utils
    ];

    home-manager = {
      extraSpecialArgs = {
        inherit
          channel
          hostName
          hostType
          pkgs-25_05
          pkgs-25_11
          ;
      };

      users.${cfg.username} = cfg.home;
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
      extraOptions = "warn-dirty = false";

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      settings = {
        experimental-features = [
          "flakes"
          "nix-command"
        ];

        trusted-users = [
          "root"
          cfg.username
        ];
      };
    };

    nixpkgs.config.allowUnfree = true;
    programs.nix-ld.enable = true;
    security.rtkit.enable = true;

    services = {
      fwupd.enable = true;

      pipewire = {
        alsa.enable = true;
        enable = true;
        pulse.enable = true;
      };

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
    home-manager.nixosModules.home-manager

    ./bluetooth
    ./dropbox
    ./monitors
    ./nautilus
    ./niri
    ./sddm
    ./steam
    ./waybar
    ./wayland
  ];

  options.nixos = let
    inherit (lib) mkOption types;

    str = types.str;
    user = import ../users;
  in {
    home = mkOption {
      default = import ../hosts/${hostType}/${channel}/${hostName}/home.nix;
      type = types.attrs;
    };

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
