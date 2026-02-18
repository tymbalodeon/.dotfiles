{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      teams-for-linux
      wireguard-tools
    ];
  };

  imports = [
    ../../../../home-manager
    ../../../../home-manager/users/work.nix
  ];
}
