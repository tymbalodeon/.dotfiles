{
  programs.jujutsu = {
    enable = true;

    settings = {
      revsets.log = "@ | ancestors(remote_bookmarks().., 2) | trunk()";

      ui = {
        default-command = "log";
        pager = "less -FRX";
      };

      user.name = "Ben Rosen";
    };
  };
}
