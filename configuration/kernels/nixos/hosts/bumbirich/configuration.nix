{...}: {
  imports = [../../configuration.nix];
  powerManagement.enable = true;

  services = {
    thermald.enable = true;
    tlp.enable = true;
  };
}
