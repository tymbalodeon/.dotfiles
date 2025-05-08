let
  defaultUser = ../../../../modules/users/default-user.nix;
in {
  home-manager.users.${defaultUser.username} = import ./home.nix;

  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix
  ];
}
