{
  config,
  nixgl,
  pkgs,
  ...
}: {
  home.packages = [pkgs.xclip];
  imports = [./home.nix];
  nixGL.packages = nixgl.packages;
  nixpkgs.config.allowUnfree = true;

  programs = {
    ghostty.package = config.lib.nixGL.wrap pkgs.ghostty;
    kitty.package = config.lib.nixGL.wrap pkgs.kitty;
  };

  targets.genericLinux.enable = true;
  xdg.mime.enable = true;
  # FIXME: get this to show up in the login screen
  # xsession = {
  #   enable = true;
  #   windowManager.xmonad.enable = true;
  # };
}
