# TODO: add /opt/paloaltonetworks/globalprotect/pangps.xml
{
  config,
  nixgl,
  pkgs,
  ...
}: {
  home.packages = [pkgs.xclip];

  imports = [
    ./home.nix
    ../../modules/xmonad
  ];

  nixGL.packages = nixgl.packages;
  nixpkgs.config.allowUnfree = true;

  programs = {
    ghostty.package = config.lib.nixGL.wrap pkgs.ghostty;
    kitty.package = config.lib.nixGL.wrap pkgs.kitty;
  };

  targets.genericLinux.enable = true;
  xdg.mime.enable = true;
}
