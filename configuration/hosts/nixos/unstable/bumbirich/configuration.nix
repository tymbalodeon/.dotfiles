{
  imports = [
    ../../../../nixos/hyprland
    ../../../../nixos/laptop
    ../../../../nixos/sddm
  ];

  sddm.defaultSession = "hyprland";
}
