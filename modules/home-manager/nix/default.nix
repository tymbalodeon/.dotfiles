{nix-index-database, ...}: {
  imports = [nix-index-database.homeModules.default];

  programs = {
    direnv = {
      enable = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };

    nh = {
      clean = {
        enable = true;
        extraArgs = "--keep-since 3d --keep 3";
      };

      enable = true;
    };

    nix-index.enable = false;
    nix-index-database.comma.enable = true;
  };
}
