{pkgs, ...}: {
  imports = [
    ../../../../nixos/laptop
    ../../../../nixos/musnix
  ];

  musnix.kernelPackages = pkgs.linuxPackages_7_0;
}
