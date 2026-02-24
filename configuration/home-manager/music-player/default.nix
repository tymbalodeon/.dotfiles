{
  config,
  hostType,
  lib,
  pkgs,
  ...
}: {
  config = let
    cfg = config.music-player;
  in {
    nushell.extraScripts = [./music.nu];

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

            center_current_song_on_change: true,

            keybinds: (
              global: { "<Space>": TogglePause },
              navigation: { "<C-m>": InvertSelection, "m": Select }
            ),

            on_song_change: ["${./notify.sh}"],
            select_current_song_on_change: true,
          )
        '';

        enable =
          if hostType == "nixos"
          then true
          else false;
      };
    };

    services.mpd = {
      enable =
        if hostType == "nixos"
        then true
        else false;

      extraConfig = ''
        max_output_buffer_size "131072"
      '';

      musicDirectory = cfg.musicDirectory;
      network.startWhenNeeded = true;
    };

    xdg =
      if pkgs.stdenv.isLinux
      then {
        configFile."rmpc/default_album_art.jpg".source = ./default_album_art.jpg;

        desktopEntries.music = {
          exec = "kitty --hold rmpc";
          icon = ./icon.png;
          name = "Music";
          type = "Application";
        };
      }
      else {};
  };

  imports = [../nushell];

  options.music-player = with lib; {
    musicDirectory = mkOption {
      default = "~/music";
      type = types.str;
    };
  };
}
