{
  channel,
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

  imports = [
    ../../hosts/${hostType}/${channel}/${hostName}/home.nix
    ../linux
  ];

  kitty.fontSize = 11.0;
  nixpkgs.config.allowUnfree = true;

  targets.genericLinux = {
    enable = true;
    nixGL.packages = nixgl.packages;
  };
}
