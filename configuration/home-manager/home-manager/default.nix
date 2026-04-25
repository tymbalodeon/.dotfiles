{
  nixgl,
  pkgs,
  ...
}: {
  home.packages = [pkgs.xclip];
  imports = [../linux];
  kitty.fontSize = 11.0;
  nixpkgs.config.allowUnfree = true;

  targets.genericLinux = {
    enable = true;
    nixGL.packages = nixgl.packages;
  };
}
