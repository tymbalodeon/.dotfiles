{
  config,
  lib,
  modulesPath,
  ...
}: {
  boot = {
    extraModulePackages = [];

    initrd = {
      availableKernelModules = [
        "nvme"
        "sd_mod"
        "uas"
        "usb_storage"
        "xhci_pci"
      ];

      kernelModules = [];
    };

    kernelModules = [];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/f22b18c8-4c19-41db-bf25-2bdb8ab17676";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/EEF0-CB37";
      fsType = "vfat";
    };
  };

  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  imports = [(modulesPath + "/installer/scan/not-detected.nix")];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  swapDevices = [];
}
