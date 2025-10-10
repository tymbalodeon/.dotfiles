{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = mkIf config.users.work.enable {
    home.activation.nb = hm.dag.entryAfter ["writeBoundary"] (
      import ../nb/entry-after.nix {
        inherit pkgs;
        nbRemote = "git@github.com:benjaminrosen/notes.git";
      }
    );

    programs = let
      email = "benrosen@upenn.edu";
    in {
      git = {
        extraConfig = {
          github.user = "benjaminrosen";
          gitlab.user = "benrosen";
        };

        userEmail = email;
      };

      jujutsu.settings.user.email = email;
    };
  };

  options.users.work.enable =
    mkEnableOption "enables user configuration for \"work\"";
}
