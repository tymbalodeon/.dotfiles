{pkgs, ...}: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs;
    [
      dejavu_fonts
      font-awesome
      gyre-fonts
      ibm-plex
      inconsolata
      liberation_ttf
      nerd-fonts.jetbrains-mono
      noto-fonts
      ubuntu-classic
    ]
    ++ (
      if stdenv.isLinux
      then [pkgs.cantarell-fonts]
      else []
    );

  imports = [../nushell];
  nushell.extraScripts = [./fonts.nu];
}
