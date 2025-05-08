let
  defaultUser = import ../users/default-user.nix;
in {
  programs.jujutsu.settings.user.email = defaultUser.emailWork;
}
