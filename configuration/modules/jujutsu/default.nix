{
  programs.jujutsu = {
    enable = true;

    settings = {
      ui = {
        default-command = "log";
        pager = "less -FRX";
      };

      user.name = "Ben Rosen";
    };
  };
}
