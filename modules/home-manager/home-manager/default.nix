{
  config,
  hostName,
  hostType,
  lib,
  nixgl,
  pkgs,
  ...
}: {
  home = {
    homeDirectory = "/home/${config.home.username}";
    packages = [pkgs.xclip];
    sessionVariables.SHELL = toString (lib.getExe pkgs.nushell);
  };

  imports = [../../../hosts/${hostType}/${hostName}/home.nix];
  nixpkgs.config.allowUnfree = true;

  targets.genericLinux = {
    enable = true;
    nixGL.packages = nixgl.packages;
  };
}
