{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.keyboard.enable {
    environment.systemPackages = with pkgs; [
      qmk
      via
    ];

    hardware.keyboard.qmk.enable = true;
    services.udev.packages = [pkgs.via];
  };

  options.keyboard.enable = lib.mkEnableOption "keyboard";
}
