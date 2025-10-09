{
  lib,
  pkgs,
  ...
}: {
  home.activation.nb = lib.hm.dag.entryAfter ["writeBoundary"] (
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
}
