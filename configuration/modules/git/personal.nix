{
  programs.git = let
    defaultUser = import ../users/default-user.nix;
  in {
    extraConfig = let
      remoteUser = defaultUser.gitlabUserPersonal;
    in {
      github.user = remoteUser;
      gitlab.user = remoteUser;
    };

    userEmail = defaultUser.emailPersonal;
  };
}
