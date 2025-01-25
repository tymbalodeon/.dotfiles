{
  inputs,
  pkgs,
  ...
}: {
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  environment.systemPackages = with pkgs; [
    firefox
    git
    helix
    hyprpaper
    xdg-utils
  ];

  hardware.bluetooth.enable = true;

  home-manager = {
    extraSpecialArgs = rec {
      inherit inputs;
      inherit (inputs) nushell-syntax;
    };

    users."benrosen" = import ./home.nix;
    useGlobalPkgs = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  imports = [inputs.home-manager.nixosModules.default];
  networking = {networkmanager.enable = true;};

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
    hyprland.enable = true;
    nix-ld.enable = true;

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };

  security.rtkit.enable = true;

  services = {
    greetd = {
      enable = true;

      settings.default_session = {
        command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet \
            --asterisks \
            --cmd Hyprland \
            --remember \
            --time
        '';

        user = "greeter";
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };

  system.stateVersion = "23.11";
  time.timeZone = "America/New_York";

  users.users.benrosen = {
    isNormalUser = true;
    description = "Ben Rosen";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.nushell;
  };
}
