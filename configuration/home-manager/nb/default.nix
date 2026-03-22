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
      activation.nb = let
        git = "${pkgs.git}/bin/git";
      in
        lib.hm.dag.entryAfter ["writeBoundary"]
        ''
          remotes=(${lib.concatStringsSep " " cfg.remotes})
          nbHome="$HOME/.nb"
          notebooks=$(ls $nbHome)
          index=0

          for remote in "''${remotes[@]}"; do
            if [[ "$index" = 0 ]]; then
              name=home
            else
              url=''${remote/git@/}
              url=''${url/.com/}

              read domain user name < <(
                echo $url |
                ${pkgs.gawk}/bin/awk --field-separator [/:] '{print $1, $(NF-1), $NF}'
              )

              name=''${name/.git/}
              name=''${domain}-''${user}-''${name}
            fi

            if [[ ! " ''${notebooks[*]} " =~ [[:space:]]$name[[:space:]] ]]; then
              directory="$nbHome/$name"

              mkdir --parents $directory
              cd $directory

              ${git} init
              ${git} remote add origin $remote
            fi

            index+=1
          done
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
      (pkgs.writeText "nb.nu" ''
        use ${./get-nb-dir.nu} get-nb-dir

        # Cd to the `nb` home  directory
        def --env "nb cd" [] {
          cd (nb settings get nb_dir | path join (nb notebooks current))
        }
      '')

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
