{
  hostName,
  isNixOS,
  pkgs,
  ...
}: rec {
  home.username = username;

  home-manager.users.${username} = let
    system = with pkgs.stdenv;
      if isDarwin
      then "darwin"
      else if isLinux
      then "linux"
      else if isNixOS
      then "nixos"
      else "";
  in
    import ../../systems/${system}/hosts/${hostName}/home.nix;

  imports = [
    ./benrosen.nix
    ./darwin.nix
    ./linux.nix
    ./nixos.nix
    ./work.nix
  ];

  name = "Ben Rosen";
  programs.jujutsu.settings.user.name = name;
  username = "benrosen";
}
