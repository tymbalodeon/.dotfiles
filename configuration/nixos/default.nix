{
  channel,
  config,
  hostName,
  hostType,
  lib,
  pkgs,
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
      popsicle
      xdg-utils
    ];

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

    nix.settings.trusted-users = [
      "root"
      cfg.username
    ];

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

  imports = let
    hostPath = file: ../hosts/${hostType}/${channel}/${hostName}/${file};
  in
    [
      ./bluetooth
      ./display-manager
      ./home-manager
      (hostPath "hardware.nix")
      ./idle
      ./monitors
      ./musnix
      ./nautilus
      ./niri
      ../nix
      ./solaar
      ./steam
      ./stylix
      ./waybar
      ./wayland
    ]
    ++ (let
      hostConfigurationFile = hostPath "configuration.nix";
    in
      if builtins.pathExists hostConfigurationFile
      then [hostConfigurationFile]
      else []);

  options.nixos = let
    inherit (lib) mkOption types;

    inherit (types) str;
    user = import ../users;
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
