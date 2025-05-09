{
  lib,
  pkgs,
  ...
}: {
  home = let
    defaultUser = import ./default-user.nix;
  in
    {
      username = defaultUser.username;
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {homeDirectory = defaultUser.homeDirectoryDarwin;};
}
