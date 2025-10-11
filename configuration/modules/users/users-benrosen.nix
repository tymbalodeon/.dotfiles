{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = mkIf config.users-benrosen.enable {
    home.activation.nb = hm.dag.entryAfter ["writeBoundary"] (
      import ../nb/entry-after.nix {
        inherit pkgs;
        nbRemote = "git@github.com:tymbalodeon/notes.git";
      }
    );
  };

  options.users-benrosen.enable =
    mkEnableOption "enables user configuration for \"benrosen\"";
}
