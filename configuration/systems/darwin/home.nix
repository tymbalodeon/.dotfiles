{
  imports = [
    ../../modules/kitty
    ../../modules/nushell
    ../common/home.nix
  ];

  kitty.font_size = 11.0;
  nushell.configDirectory = "Library/Application Support/nushell";
  programs.helix.settings.theme = "catppuccin_mocha";
}
