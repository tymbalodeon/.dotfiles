{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    system-config-printer
  ];

  services = {
    ipp-usb.enable = true;

    printing = {
      drivers = [pkgs.postscript-lexmark];
      enable = true;
    };
  };
}
