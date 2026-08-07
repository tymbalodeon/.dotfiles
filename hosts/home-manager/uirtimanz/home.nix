{pkgs, ...}: {
  home.packages = with pkgs; [
    teams-for-linux
    wireguard-tools
  ];

  imports = [
    ../../../modules/home-manager/editor
    ../../../modules/home-manager/shell/nushell
    ../../../modules/home-manager/users/work.nix
  ];

  nushell.extraScripts = [{source = ./wireguard.nu;}];
}
