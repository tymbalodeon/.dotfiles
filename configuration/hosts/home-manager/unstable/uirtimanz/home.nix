{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      slack
      teams-for-linux
      wireguard-tools
    ];
  };

  imports = [
    ../../../../home-manager
    ../../../../home-manager/nushell
    ../../../../home-manager/users/work.nix
  ];

  nushell.extraScripts = [
    ./wireguard.nu
  ];
}
