{
  home-manager,
  nushell-syntax,
  ...
}: {
  home-manager = {
    extraSpecialArgs = {inherit nushell-syntax;};
    users.benrosen = import ./home.nix;
  };

  imports = [home-manager.darwinModules.home-manager];
  users.users.benrosen.home = "/Users/benrosen";

  system = {
    activationScripts.postUserActivation.text = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    stateVersion = 6;
  };
}
