{inputs, ...}: {
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users.benrosen = import ./home.nix;
  };

  imports = [inputs.home-manager.darwinModules.home-manager];
  users.users.benrosen.home = "/Users/benrosen";

  system = {
    activationScripts.postUserActivation.text = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    stateVersion = 6;
  };
}
