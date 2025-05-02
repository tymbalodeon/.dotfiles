{
  home.homeDirectory = "/home/benrosen";

  imports = [
    ../../home.nix
    # TODO: use loop function from main home.nix, and possibly store that
    # function in a global variable that can be accessed here without re-defining.
    ./modules/fonts
    ./modules/ghostty
    ./modules/kitty
    ./modules/nushell
    ./modules/tinty
  ];
}
