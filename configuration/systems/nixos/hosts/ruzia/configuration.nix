{
  home-manager.users.benrosen = import ./home.nix;

  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix
  ];
}
