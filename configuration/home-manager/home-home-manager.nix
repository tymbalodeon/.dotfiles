# TODO: add /opt/paloaltonetworks/globalprotect/pangps.xml
{
  config,
  nixgl,
  pkgs,
  pkgs-stable,
  ...
}: {
  home = {
    homeDirectory = "/home/${config.home.username}";
    packages = [pkgs.xclip];
  };

  imports = [
    ./home-linux.nix
    ./xmonad
  ];

  kitty.font_size = 11.0;

  nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      (final: prev: {
        readability-cli = pkgs-stable.readability-cli;
      })
    ];
  };

  targets.genericLinux = {
    enable = true;
    nixGL.packages = nixgl.packages;
  };
}
