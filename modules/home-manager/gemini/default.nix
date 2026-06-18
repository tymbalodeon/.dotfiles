{
  config,
  pkgs,
  ...
}: let
  amforaBookmarksPath = "amfora/bookmarks.xml";
in {
  home.packages = [pkgs.lagrange];
  imports = [../secrets];
  programs.amfora.enable = true;
  sops.secrets.${amforaBookmarksPath} = {};

  xdg.dataFile.${amforaBookmarksPath}.source =
    config.lib.file.mkOutOfStoreSymlink config.sops.secrets.${amforaBookmarksPath}.path;
}
