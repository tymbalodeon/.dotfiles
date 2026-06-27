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

  # FIXME: make writeable and merge local and remote
  xdg.dataFile.${amforaBookmarksPath}.source =
    config.sops.secrets.${amforaBookmarksPath}.path;
}
