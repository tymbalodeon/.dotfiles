{pkgs, ...}: {
  home.packages = with pkgs; [
    maestral
  ];

  imports = [../nushell];
  nushell.extraScripts = [./storage.nu];
  programs.rclone.enable = true;
}
