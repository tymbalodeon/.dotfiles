{
  config,
  hostName,
  hostType,
  nixgl,
  pkgs,
  ...
}: {
  home = {
    homeDirectory = "/home/${config.home.username}";
    packages = [pkgs.xclip];
  };

  imports = [../../../hosts/${hostType}/${hostName}/home.nix];
  nixpkgs.config.allowUnfree = true;

  targets.genericLinux = {
    enable = true;
    nixGL.packages = nixgl.packages;
  };
}
