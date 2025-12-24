{pkgs, ...}: {
  programs.steam = {
    dedicatedServer.openFirewall = true;
    enable = true;
    package = pkgs.steam.override {extraArgs = "-system-composer";};
    remotePlay.openFirewall = true;
  };
}
