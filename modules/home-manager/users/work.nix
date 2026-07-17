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
    ../note
    ../version-control
  ];

  options.work.user = let
    inherit (lib) mkOption types;
    inherit (types) listOf str;

    getUserValue = attr: (
      if builtins.hasAttr attr defaultUser
      then defaultUser.${attr}
      else config.user.${attr}
    );

    defaultUser = import ../../users/work.nix;
  in {
    email = mkOption {
      default = builtins.elemAt defaultUser.email.addresses 0;
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
