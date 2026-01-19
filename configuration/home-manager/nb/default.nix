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
          nb_directory=$HOME/.nb
          nb_home_notebook=$nb_directory/home
          nb_current_notebook=$nb_directory/.current

          if [[ ! -d $nb_home_notebook ]]; then
          	echo Creating "$nb_home_notebook"
          	mkdir --parents "$nb_home_notebook"
          	${git} -C "$nb_home_notebook" init
          fi

          if [[ ! -f $nb_current_notebook ]]; then
            echo Setting the current notebook to \"home\"
          	echo home >"$nb_current_notebook"
          fi

          if [[ -n "${cfg.remote}" ]]; then
          	origin=$(
              ${git} -C "$nb_home_notebook" remote get-url origin 2>/dev/null ||
                echo ""
            )

          	if [[ -n $origin ]] && [[ $origin != "${cfg.remote}" ]]; then
          		echo Setting nb remote to "${cfg.remote}"
          		${git} -C "$nb_home_notebook" remote set-url origin "${cfg.remote}"
          	elif [[ -z $origin ]]; then
          		echo Adding nb remote "${cfg.remote}"
          		${git} -C "$nb_home_notebook" remote add origin "${cfg.remote}"
          	fi
          fi
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

  options.nb.remote = with lib;
    mkOption {
      default = config.user.nbRemote;
      type = types.str;
    };
}
