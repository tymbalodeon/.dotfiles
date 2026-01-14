{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    cfg = config.git;
  in {
    home.packages = with pkgs; [
      gh
      glab
      # TODO: replace this with my own version?
      siketyan-ghr
    ];

    programs = {
      delta = {
        enable = true;
        enableGitIntegration = true;

        options = {
          diff-so-fancy = true;
          navigate = true;
          syntax-theme = "base16";
        };
      };

      git = {
        enable = true;

        settings = {
          alias = {
            a = "add";
            b = "branch";
            ch = "checkout";
            cl = "clone";
            cm = "commit -m";
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
            pl = "pull";
            p = "push";
            rh = "reset --hard";
            r = "restore";
            rs = "restore --staged";
            sh = "stash";
            sl = "stash list";
            sp = "stash pop";
            st = "status";
            sw = "switch";
            tg = "tag";
            tracked = "ls-tree --full-tree --name-only -r HEAD";
            tr = "tracked";
          };

          core.excludesfile = "~/.gitignore_global";
          default.push = "upstream";
          diff.colorMoved = "default";
          github.user = cfg.github.user;
          gitlab.user = cfg.gitlab.user;
          init.defaultBranch = "trunk";

          merge = {
            conflictstyle = "diff3";
            ff = "only";
          };

          pull.rebase = false;
          push.default = "current";

          user = {
            email = cfg.userEmail;
            name = cfg.userName;
          };
        };
      };
    };
  };

  options.git = let
    inherit (lib) mkOption types;

    str = types.str;
    user = import ../../users;
  in {
    github.user = mkOption {
      default = user.githubUsername;
      type = str;
    };

    gitlab.user = mkOption {
      default = user.gitlabUsername;
      type = str;
    };

    userEmail = mkOption {
      default = user.email;
      type = str;
    };

    userName = mkOption {
      default = user.name;
      type = str;
    };
  };
}
