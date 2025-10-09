{pkgs, ...}: {
  home.packages = [pkgs.jjui];

  programs.jujutsu = {
    enable = true;

    settings = {
      revsets.log = "@ | ancestors(remote_bookmarks().., 2) | trunk()";

      ui = {
        default-command = "log";
        pager = "less -FRX";
      };

      # TODO: remove me if this works via the users module
      # user.name = "Ben Rosen";
    };
  };
}
