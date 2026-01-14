# TODO: add /opt/paloaltonetworks/globalprotect/pangps.xml
{
  config,
  nixgl,
  pkgs,
  ...
}: {
  home = {
    homeDirectory = "/home/${config.home.username}";
    packages = [pkgs.xclip];
  };

  imports = [
    ../linux
    ../xmonad
  ];

  kitty.font_size = 11.0;
  nixpkgs.config.allowUnfree = true;

  targets.genericLinux = {
    enable = true;
    nixGL.packages = nixgl.packages;
  };
}
