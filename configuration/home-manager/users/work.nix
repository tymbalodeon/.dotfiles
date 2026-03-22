{
  config,
  lib,
  ...
}: {
  config = let
    cfg = config.work.user;
  in {
    git.github.user = cfg.githubUsername;
    git.gitlab.user = cfg.gitlabUsername;
    git.userEmail = cfg.email;
    jujutsu.email = cfg.email;
    nb.remotes = cfg.nbRemotes;
  };

  imports = [
    ../git
    ../jujutsu
    ../nb
  ];

  options.work.user = let
    inherit (lib) mkOption types;
    inherit (types) listOf str;

    getUserValue = attr: (
      if builtins.hasAttr attr user
      then user.${attr}
      else config.user.${attr}
    );

    user = import ../../users/work.nix;
  in {
    email = mkOption {
      default = getUserValue "email";
      type = str;
    };

    githubUsername = mkOption {
      default = getUserValue "githubUsername";
      type = str;
    };

    gitlabUsername = mkOption {
      default = getUserValue "gitlabUsername";
      type = str;
    };

    nbRemotes = mkOption {
      default = getUserValue "nbRemotes";
      type = listOf str;
    };
  };
}
