{
  homeDirectory = let
    username = (import ./default.nix).username;
  in
    /home/${username};
}
