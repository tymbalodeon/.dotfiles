{
  imports = [
    ../../home.nix
    {programs.nushell.configDirectory = "Library/Application Support/nushell";}
    ../../modules/users/home.nix
  ];
}
