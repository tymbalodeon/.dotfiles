{
  lib,
  pkgs,
  ...
}: {
  home = let
    defaultUser = import ./default-user.nix;
  in
    {
      inherit (defaultUser) username;
    }
    // lib.mkIf pkgs.stdenv.isDarwin {homeDirectory = defaultUser.homeDirectoryDarwin;};
}
