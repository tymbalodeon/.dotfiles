{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    cfg = config.nb;
  in {
    home = {
      # TODO: handle $VERBOSE and $DRY_RUN
      # TODO: is it possible to git pull the remote notes here?
      activation.nb =
        lib.hm.dag.entryAfter ["writeBoundary"]
        ''
          echo ${pkgs.nushell}/bin/nu
          echo ${./activation.nu}
          # ${lib.concatStringsSep " " cfg.remotes}
        '';

      file = {
        ".nb/.plugins/csv.nb-plugin".source = ./csv.nb-plugin;
        ".nb/.plugins/tags.nb-plugin".source = ./tags.nb-plugin;
      };

      packages = with pkgs; [
        csvlens
        nb
        pandoc
        readability-cli
        ripgrep
        socat
        tig
        w3m
      ];
    };

    nushell.extraScripts = [
      ./nb-cd.nu
      ./pens.nu
    ];
  };

  imports = [
    ../bash
    ../bat
    ../git
    ../helix
    ../helix/markdown
    ../nushell
  ];

  options.nb.remotes = let
    inherit (lib) mkOption types;
    inherit (types) listOf str;
  in
    mkOption {
      default = config.user.nbRemotes;
      type = listOf str;
    };
}
