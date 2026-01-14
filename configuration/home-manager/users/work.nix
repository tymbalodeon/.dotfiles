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
    nb.remote = cfg.nbRemote;
  };

  imports = [
    ../git
    ../jujutsu
    ../nb
  ];

  options.work.user = let
    getUserValue = attr: (
      if builtins.hasAttr attr user
      then user.${attr}
      else config.user.${attr}
    );

    user = import ../../users/work.nix;
  in
    with lib; {
      email = mkOption {
        default = getUserValue "email";
        type = types.str;
      };

      githubUsername = mkOption {
        default = getUserValue "githubUsername";
        type = types.str;
      };

      gitlabUsername = mkOption {
        default = getUserValue "gitlabUsername";
        type = types.str;
      };

      nbRemote = mkOption {
        default = getUserValue "nbRemote";
        type = types.str;
      };
    };
}
