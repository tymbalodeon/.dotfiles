{
  config,
  lib,
  modulesPath,
  ...
}: {
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot = {
    extraModulePackages = [];

    initrd = {
      availableKernelModules = [
        "nvme"
        "sd_mod"
        "thunderbolt"
        "uas"
        "usbhid"
        "xhci_pci"
      ];

      kernelModules = [];
    };

    kernelModules = ["kvm-amd"];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/11e5655d-29c2-4446-a9d7-bb9e50d9abf3";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/DBB6-43C0";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  swapDevices = [
    {device = "/dev/disk/by-uuid/94803c5b-d1f9-4432-99b2-3eafcf45be5a";}
  ];
}
