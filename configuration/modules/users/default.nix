{
  hostName,
  isNixOS,
  pkgs,
  ...
}: rec {
  home.username = username;
  home-manager.users.${username} = import ./home.nix;

  imports = with pkgs.stdenv;
    if isDarwin
    then [./darwin.nix]
    else if isLinux
    then [./linux.nix]
    else
      []
      ++ (
        if isNixOS
        then [./nixos.nix]
        else []
      )
      ++ (
        if
          (
            elem "${hostName}.nix" (
              map (file: file.name) (pkgs.lib.attrsToList (readDir ../users))
            )
          )
        then [./${hostName}.nix]
        else []
      );

  name = "Ben Rosen";
  programs.jujutsu.settings.user.name = name;
  username = "benrosen";
}
