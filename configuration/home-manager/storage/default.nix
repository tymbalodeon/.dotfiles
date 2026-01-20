{pkgs, ...}: {
  home.packages = with pkgs; [
    maestral
    rclone
  ];

  imports = [../nushell];
  nushell.extraScripts = [./storage.nu];
}
