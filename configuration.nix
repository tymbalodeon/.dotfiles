{ inputs, pkgs, ... }:

{
  imports = [ inputs.home-manager.nixosModules.default ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  environment.systemPackages = with pkgs; [ firefox git helix hyprpaper ];
  hardware.bluetooth.enable = true;

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users."benrosen" = import ./home/linux.nix;
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

  networking = { networkmanager.enable = true; };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  programs = {
    hyprland.enable = true;
    waybar.enable = true;
  };

  security.rtkit.enable = true;

  services = {
    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  sound.enable = false;
  system.stateVersion = "23.11";
  time.timeZone = "America/New_York";

  users.users.benrosen = {
    isNormalUser = true;
    description = "Ben Rosen";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.nushell;
  };
}
