{pkgs, ...}: {
  home.packages = with pkgs; [
    teams-for-linux
    wireguard-tools
  ];

  imports = [
    ../../../../home-manager/nushell
    ../../../../home-manager/users/work.nix
  ];

  nushell.extraScripts = [{source = ./wireguard.nu;}];
}
