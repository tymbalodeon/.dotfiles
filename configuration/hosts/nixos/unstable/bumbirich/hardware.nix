{
  config,
  lib,
  modulesPath,
  ...
}: {
  boot = {
    extraModulePackages = [];

    initrd.availableKernelModules = [
      "nvme"
      "sd_mod"
      "uas"
      "usb_storage"
      "xhci_pci"
    ];

    initrd.kernelModules = [];
    kernelModules = ["kvm-intel"];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/6949970f-0d71-485a-9a19-8340859a9cd3";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/7850-589D";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
  };

  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  imports = [(modulesPath + "/installer/scan/not-detected.nix")];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  swapDevices = [
    {device = "/dev/disk/by-uuid/ae38cb7e-b1a8-48e1-b549-0ad0f775bd08";}
  ];
}
