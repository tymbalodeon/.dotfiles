{
  nix-index-database,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    comma
  ];

  imports = [nix-index-database.homeModules.default];
}
