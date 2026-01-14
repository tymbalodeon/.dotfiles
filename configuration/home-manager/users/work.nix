{
  config,
  lib,
  ...
}: {
  config = let
    cfg = config.user;
  in {
    imports = [
      ../git
      ../jujutsu
      ../nb
    ];

    git.github.user = cfg.githubUsername;
    git.gitlab.user = cfg.gitlabUsername;
    git.userEmail = cfg.email;
    jujutsu.email = cfg.email;
    nb.remote = cfg.nbRemote;
  };

  options.work.user = let
    user = import ../../users/work.nix;
  in
    with lib; {
      email = mkOption {
        default = user.email;
        type = types.str;
      };

      githubUsername = mkOption {
        default = user.githubUsername;
        type = types.str;
      };

      gitlabUsername = mkOption {
        default = user.gitlabUsername;
        type = types.str;
      };

      nbRemote = mkOption {
        default = user.nbRemote;
        type = types.str;
      };
    };
}
