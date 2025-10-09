{pkgs, ...}: {
  home.packages = with pkgs; [
    gh
    glab
    siketyan-ghr
  ];

  programs.git = {
    aliases = {
      a = "add";
      b = "branch";
      cm = "commit -m";
      ch = "checkout";
      cl = "clone";
      d = "diff";
      ds = "diff --staged";

      l = let
        commit = "%C(auto)%h%d%C(reset)";
        time = "%C(dim)%ar%C(reset)";
        message = "%C(bold)%s%C(reset)";
        author = "%C(dim blue)(%an)%C(reset)";
        format = "${commit} ${time} ${message} ${author}";
      in "log --graph --pretty=format:'${format}'";

      last = "log -1 HEAD --stat";
      m = "merge";
      p = "push";
      pl = "pull";
      r = "restore";
      rh = "reset --hard";
      rs = "restore --staged";
      s = "status";
      sh = "stash";
      sl = "stash list";
      sp = "stash pop";
      sw = "switch";
      tg = "tag";
      tracked = "ls-tree --full-tree --name-only -r HEAD";
      tr = "tracked";
    };

    delta = {
      enable = true;

      options = {
        diff-so-fancy = true;
        navigate = true;
        # TODO: tie this theme to the others
        # https://github.com/catppuccin/delta
        syntax-theme = "gruvbox-dark";
      };
    };

    enable = true;

    extraConfig = {
      core.excludesfile = "~/.gitignore_global";
      default.push = "upstream";
      diff.colorMoved = "default";
      init.defaultBranch = "trunk";

      merge = {
        conflictstyle = "diff3";
        ff = "only";
      };

      pull.rebase = false;
      push.default = "current";
    };

    userName = "Ben Rosen";
  };
}
