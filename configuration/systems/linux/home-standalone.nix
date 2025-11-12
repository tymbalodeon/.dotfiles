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
    ./home.nix
    ../../modules/xmonad
  ];

  kitty.font_size = 11.0;
  nixpkgs.config.allowUnfree = true;
  programs.ghostty.package = config.lib.nixGL.wrap pkgs.ghostty;

  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    enable = true;
    polarity = "dark";
  };

  targets.genericLinux = {
    enable = true;
    nixGL.packages = nixgl.packages;
  };
}
