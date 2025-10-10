{
  hostName,
  isNixOS,
  pkgs,
  ...
}: let
  username = (import ./user.nix).username;
in {
  home-manager.users.${username} = let
    system = with pkgs.stdenv;
      if isDarwin
      then "darwin"
      else if isNixOS
      then "nixos"
      else if isLinux
      then "linux"
      else "";
  in
    import ../../systems/${system}/hosts/${hostName}/home.nix;
}
