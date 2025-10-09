let
  username = (import ./default.nix).username;
in rec {
  homeDirectory = /Users/${username};
  users.users.${username}.home = homeDirectory;
  system.primaryUser = username;
}
