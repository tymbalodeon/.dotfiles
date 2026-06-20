{
  programs.nh = {
    clean = {
      enable = true;
      extraArgs = "--keep-since 3d --keep 3";
    };

    enable = true;
  };
}
