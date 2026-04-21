{
  programs.nh = {
    clean = {
      enable = true;
      extraArgs = "--keep-since 3d --keep 3";
    };

    enable = true;
    # flake = "/home/user/my-nixos-config"; # sets NH_OS_FLAKE variable for you
  };
}
