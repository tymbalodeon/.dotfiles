{pkgs, ...}: {
  home.packages = with pkgs; [brave dysk];

  imports = [
    ../../home.nix
    ../../modules/ghostty
  ];
}
