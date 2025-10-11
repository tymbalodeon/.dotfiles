let
  user = import ./user.nix;
in {
  home.username = user.username;

  imports = [
    ./users-benrosen.nix
    ./users-work.nix
  ];

  programs = let
    email = "benjamin.j.rosen@gmail.com";
  in {
    git = {
      extraConfig = {
        github.user = "tymbalodeon";
        gitlab.user = "benjaminrosen";
      };

      userEmail = email;
    };

    jujutsu.settings.user = {
      email = email;
      name = user.name;
    };
  };
}
