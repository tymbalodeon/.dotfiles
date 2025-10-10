let
  user = import ./user.nix;
in {
  home.username = user.username;

  imports = [
    ./users-benrosen.nix
    ./users-work.nix
  ];

  programs.jujutsu.settings.user.name = user.name;
}
