{musnix, ...}: {
  imports = [musnix.nixosModules.musnix];

  musnix = {
    enable = true;
    kernel.realtime = true;
  };
}
