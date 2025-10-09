{
  inputs,
  isNixOS,
  pkgs,
  ...
}: {
  home = {
    file = {
      ".config/rmpc/notify.sh".source = ./notify.sh;
      ".config/rmpc/default_album_art.jpg".source = ./default_album_art.jpg;
    };

    packages = with pkgs;
      [
        mpc
      ]
      ++ (
        if isNixOS
        then []
        else [
          # TODO: remove when mpd works on Darwin
          inputs.nixpkgs-mpd.legacyPackages.x86_64-darwin.mpd
        ]
      );
  };

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
      config = ''
        #![enable(implicit_some)]
        #![enable(unwrap_newtypes)]
        #![enable(unwrap_variant_newtypes)]

        (
          on_song_change: ["~/.config/rmpc/notify.sh"],
        )
      '';

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
