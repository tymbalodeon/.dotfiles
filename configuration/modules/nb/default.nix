{pkgs, ...}: {
  home.packages = with pkgs; [
    nb
    pandoc
    socat
    tig
    w3m
  ];

  imports = [../helix/markdown];
}
