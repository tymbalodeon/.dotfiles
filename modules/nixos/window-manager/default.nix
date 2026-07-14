{niri, ...}: {
  imports = [niri.nixosModules.default];
  programs.niri.enable = true;
}
