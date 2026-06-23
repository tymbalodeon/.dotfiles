{pkgs, ...}: {
  fonts.fontconfig.enable = true;

  home.packages = let
    anrtFonts =
      map
      (font: pkgs.${font.name})
      (import ../../fonts/anrt-fonts.nix);

    fonts = with pkgs;
      [
        adwaita-fonts
        # andika
        cantarell-fonts
        dejavu_fonts
        fanwood
        # fira
        font-awesome
        gentium
        gentium-book
        google-fonts
        goudy-bookletter-1911
        gyre-fonts
        # ibm-plex
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
      ++ anrtFonts;

    programs = with pkgs; [
      font-manager
      fontpreview
    ];
  in
    fonts ++ programs;

  imports = [../shell/nushell];
  nushell.extraScripts = [{source = ./font.nu;}];
}
