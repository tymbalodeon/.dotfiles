{
  programs.git = let
    defaultUser = import ../users/default-user.nix;
  in {
    extraConfig = {
      github.user = defaultUser.githubUserWork;
      gitlab.user = defaultUser.gitlabUserWork;
    };

    userEmail = defaultUser.emailWork;
  };
}
