{config, ...}: {
  boot.kernelModules = ["i2c-dev"];
  hardware.i2c.enable = true;
  services.udev.extraRules = ''KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"'';
  users.users.${config.nixos.username}.extraGroups = ["i2c"];
}
