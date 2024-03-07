{ self, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ ];
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.hostPlatform = "x86_64-darwin";
  programs.zsh.enable = true;
  services.nix-daemon.enable = true;

  system = {
    configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 4;
  };
}
