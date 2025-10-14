{
  imports = [
    ../common/home.nix
    ../../modules/nushell
  ];

  nushell.configDirectory = "Library/Application Support/nushell";
}
