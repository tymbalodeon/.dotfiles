{
  config,
  lib,
  pkgs,
  ...
}: let
  amforaBookmarksPath = "amfora/bookmarks.xml";
in {
  home = {
    activation.gemini = let
      script =
        pkgs.writeScript "activate-gemini"
        # nushell
        (
          ''
            def bookmarks-path [] {
              "${config.xdg.dataHome}"
              | path join ${amforaBookmarksPath}
            }

            def remote-bookmarks [] {
              try {
                open --raw ${config.sops.secrets.${amforaBookmarksPath}.path}
                | from xml --allow-dtd
              } catch {
                {}
              }
            }
          ''
          + builtins.readFile ./home-activation.nu
        );
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        run ${lib.getExe pkgs.nushell} "${script}"
      '';

    packages = [pkgs.lagrange];
  };

  imports = [../secrets];
  programs.amfora.enable = true;
  sops.secrets.${amforaBookmarksPath} = {};
}
