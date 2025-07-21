{pkgs, ...}: {
  home = let
    defaultUser = import ../../../../modules/users/default-user.nix;
  in {
    packages = with pkgs; [
      # TODO: find a way to add this to known programs
      teams-for-linux
      wireguard-tools
      # FIXME: this doesn't work.
      # zoom-us
    ];

    inherit (defaultUser) username;
  };

  imports = [
    ../../home-standalone.nix
    ../../../../modules/work
  ];
}
