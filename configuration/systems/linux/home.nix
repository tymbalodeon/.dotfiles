{
  home.homeDirectory = "/home/benrosen";

  imports = [
    ../../home.nix
    ./modules/fonts
    ./modules/ghostty
    ./modules/kitty
    ./modules/nushell
    ./modules/tinty
  ];
}
