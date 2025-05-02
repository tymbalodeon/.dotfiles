{
  home.homeDirectory = "/Users/benrosen";

  imports = [
    ../../home.nix
    {programs.nushell.configDirectory = "Library/Application Support/nushell";}
  ];
}
