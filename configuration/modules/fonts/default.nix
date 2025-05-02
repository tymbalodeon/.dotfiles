{pkgs, ...}: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs;
    [
      dejavu_fonts
      fira-code
      font-awesome
      gyre-fonts
      ibm-plex
      inconsolata
      liberation_ttf
      nerd-fonts.jetbrains-mono
      noto-fonts
      ubuntu_font_family
    ]
    ++ (
      if stdenv.isLinux
      then [pkgs.cantarell-fonts]
      else []
    );
}
