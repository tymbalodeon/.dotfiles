{pkgs, ...}: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs;
    [
      adwaita-fonts
      andika
      dejavu_fonts
      fanwood
      fira
      font-awesome
      gentium
      goudy-bookletter-1911
      gyre-fonts
      ibm-plex
      inconsolata
      inter
      iosevka
      jost
      lato
      liberation_ttf
      nerd-fonts.iosevka-term
      nerd-fonts.iosevka-term-slab
      nerd-fonts.jetbrains-mono
      noto-fonts
      prociono
      ubuntu-classic
    ]
    ++ (
      if stdenv.isLinux
      then [pkgs.cantarell-fonts]
      else []
    );

  imports = [../nushell];
  nushell.extraScripts = [{source = ./fonts.nu;}];
}
