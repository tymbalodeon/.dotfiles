{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = mkIf config.users.benrosen.enable {
    home.activation.nb = hm.dag.entryAfter ["writeBoundary"] (
      import ../nb/entry-after.nix {
        inherit pkgs;
        nbRemote = "git@github.com:tymbalodeon/notes.git";
      }
    );

    programs = let
      email = "benjamin.j.rosen@gmail.com";
    in {
      git = {
        extraConfig = {
          github.user = "tymbalodeon";
          gitlab.user = "benjaminrosen";
        };

        userEmail = email;
      };

      jujutsu.settings.user.email = email;
    };

    options.users.benrosen.emable =
      mkEnableOption "enables user configuration for \"benrosen\"";
  };
}
