{
  programs.jujutsu = {
    enable = true;

    settings = {
      ui = {
        default-command = ["log"];
        paginate = "never";
      };

      user.name = "Ben Rosen";
    };
  };
}
