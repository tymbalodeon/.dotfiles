{
  programs.git = {
    extraConfig = let
      remoteUser = "tymbalodeon";
    in {
      github.user = remoteUser;
      gitlab.user = remoteUser;
    };

    userEmail = "benjamin.j.rosen@gmail.com";
  };
}
