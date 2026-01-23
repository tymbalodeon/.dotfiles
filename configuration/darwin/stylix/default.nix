{
  pkgs,
  stylix,
  ...
}: {
  imports = [stylix.darwinModules.stylix];
  stylix = import ../../stylix {inherit pkgs;};
}
