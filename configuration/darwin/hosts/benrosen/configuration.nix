{...}: {
  home-manager.users.benrosen = import ./home.nix;
  imports = [../../configuration.nix];
  system.defaults.menuExtraClock.IsAnalog = true;
}
