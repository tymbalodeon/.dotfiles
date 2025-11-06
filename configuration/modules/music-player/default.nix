{
  config,
  inputs,
  isNixOS,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = let
    cfg = config.music-player;
  in {
    home = {
      file = {
        ".config/rmpc/notify.sh".source = ./notify.sh;
        ".config/rmpc/default_album_art.jpg".source = ./default_album_art.jpg;
      };

      packages = with pkgs;
        [mpc]
        ++ (
          if stdenv.isDarwin
          # TODO: why doesn't this work as an overlay?
          then [inputs.nixpkgs-stable.legacyPackages.x86_64-darwin.mpd]
          else []
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
            artists: (
              album_display_mode: NameOnly,
              album_sort_by: Name,
            ),

            on_song_change: ["~/.config/rmpc/notify.sh"],
          )
        '';

        enable =
          if isNixOS
          then true
          else false;
      };
    };

    services.mpd = {
      enable =
        if isNixOS
        then true
        else false;

      musicDirectory = cfg.musicDirectory;
      network.startWhenNeeded = true;
    };
  };

  options.music-player = with types; {
    musicDirectory = mkOption {
      default = "~/music";
      type = str;
    };
  };
}
