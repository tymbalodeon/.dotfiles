{pkgs, ...}: {
  fonts.fontconfig.enable = true;

  home.packages = let
    customFonts =
      map
      (font: pkgs.${font.name})
      (import ../../fonts/fonts.nix);

    fonts = with pkgs;
      [
        adwaita-fonts
        dejavu_fonts
        drafting-mono
        fanwood
        font-awesome
        gentium
        gentium-book
        google-fonts
        goudy-bookletter-1911
        gyre-fonts
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
      ++ customFonts;

    programs = with pkgs; [
      font-manager
      fontpreview
    ];
  in
    fonts ++ programs;

  imports = [../shell/nushell];
  nushell.extraScripts = [{source = ./font.nu;}];
}
