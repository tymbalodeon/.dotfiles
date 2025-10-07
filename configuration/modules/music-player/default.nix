{
  isNixOS,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    mpc
    mpd
  ];

  programs = {
    ncmpcpp = {
      bindings = [
        {
          key = "j";
          command = "scroll_down";
        }

        {
          key = "k";
          command = "scroll_up";
        }

        {
          key = "J";
          command = ["select_item" "scroll_down"];
        }

        {
          key = "K";
          command = ["select_item" "scroll_up"];
        }
      ];

      enable =
        if pkgs.stdenv.isLinux
        then false
        else true;
    };

    rmpc = {
      enable =
        if isNixOS
        then true
        else false;
    };
  };

  services.mpd = let
    defaultUser = import ../../modules/users/default-user.nix;
  in {
    enable =
      if isNixOS
      then true
      else false;

    musicDirectory = defaultUser.musicDirectory;
    network.startWhenNeeded = true;
  };
}
