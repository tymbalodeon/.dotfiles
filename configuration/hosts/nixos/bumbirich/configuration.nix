{pkgs, ...}: {
  boot.kernelPackages = pkgs.linuxPackages_7_0;
  imports = [../../../../nixos/laptop];
}
