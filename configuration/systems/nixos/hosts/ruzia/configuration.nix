{
  # TODO: finish setting this up to control external monitor brightness
  hardware.i2c.enable = true;

  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix
  ];
}
