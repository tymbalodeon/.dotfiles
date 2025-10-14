{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      # TODO: find a way to add this to known programs
      teams-for-linux
      wireguard-tools
      # FIXME: this doesn't work.
      # zoom-us
    ];
  };

  imports = [
    ../../../common/hosts/work.nix
    ../../home-standalone.nix
  ];
}
