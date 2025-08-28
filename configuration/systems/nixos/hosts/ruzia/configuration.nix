let
  defaultUser = import ../../../../modules/users/default-user.nix;
in {
  # TODO: finish setting this up to control external monitor brightness
  hardware.i2c.enable = true;
  home-manager.users.${defaultUser.username} = import ./home.nix;

  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix
  ];
}
