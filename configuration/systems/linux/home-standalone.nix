# TODO: add /opt/paloaltonetworks/globalprotect/pangps.xml
{
  config,
  nixgl,
  pkgs,
  ...
}: {
  home = let
    defaultUser = import ../../modules/users/default-user.nix;
  in {
    homeDirectory = defaultUser.homeDirectoryLinux;
    packages = [pkgs.xclip];
  };

  imports = [
    ./home.nix
    ../../modules/xmonad
  ];

  nixGL.packages = nixgl.packages;
  nixpkgs.config.allowUnfree = true;
  programs.ghostty.package = config.lib.nixGL.wrap pkgs.ghostty;
  targets.genericLinux.enable = true;
  xdg.mime.enable = true;
}
