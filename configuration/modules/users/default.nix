{pkgs, ...}: {
  home = let
    defaultUser = import ./default-user.nix;
  in {
    homeDirectory =
      if pkgs.stdenv.isDarwin
      then defaultUser.homeDirectoryDarwin
      else defaultUser.homeDirectoryLinux;

    username = defaultUser.username;
  };
}
