{
  pkgs,
  stylix,
  ...
}: {
  imports = [stylix.nixosModules.stylix];
  stylix = import ../../stylix {inherit pkgs;};
}
