{pkgs, ...}: {
  displayManager.defaultSession = "hyprland";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      mesa
    ];
  };

  imports = [
    ../../../../nixos/display-manager
    ../../../../nixos/hyprland
    ../../../../nixos/laptop
  ];
}
