{pkgs, ...}: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    adwaita-fonts
    andika
    cantarell-fonts
    dejavu_fonts
    fanwood
    fira
    font-awesome
    font-manager
    fontpreview
    gentium
    gentium-book
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
  ];

  imports = [../nushell];
  nushell.extraScripts = [{source = ./font.nu;}];
}
