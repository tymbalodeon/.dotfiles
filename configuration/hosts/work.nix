let
  email = "benrosen@upenn.edu";
in {
  imports = [
    ../home-manager/git
    ../home-manager/jujutsu
    ../home-manager/nb
  ];

  git.github.user = "benjaminrosen";
  git.gitlab.user = "benrosen";
  git.userEmail = email;
  jujutsu.email = email;
  nb.remote = "git@github.com:benjaminrosen/notes.git";
}
