{
  lib,
  pkgs,
  ...
}: {
  home = {
    # TODO: handle $VERBOSE and $DRY_RUN
    activation.nb = let
      defaultUser = import ../users/default-user.nix;
      git = "${pkgs.git}/bin/git";
    in let
      nbRemote =
        if defaultUser ? nbRemote
        then defaultUser.nbRemote
        else "";
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        NB_DIRECTORY=$HOME/.nb
        NB_HOME_NOTEBOOK=$NB_DIRECTORY/home
        NB_CURRENT_NOTEBOOK=$NB_DIRECTORY/.current

        if [[ ! -d $NB_HOME_NOTEBOOK ]]; then
        	echo Creating "$NB_HOME_NOTEBOOK"
        	mkdir --parents "$NB_HOME_NOTEBOOK"
        	${git} -C "$NB_HOME_NOTEBOOK" init
        fi

        if [[ ! -f $NB_CURRENT_NOTEBOOK ]]; then
          echo Setting the current notebook to \"home\"
        	echo home >"$NB_CURRENT_NOTEBOOK"
        fi

        if [[ -n ${nbRemote} ]]; then
        	origin=$(
            ${git} -C "$NB_HOME_NOTEBOOK" remote get-url origin 2>/dev/null ||
              echo ""
          )

        	if [[ -n $origin ]] && [[ $origin != "${nbRemote}" ]]; then
        		echo Setting nb remote to "${nbRemote}"
        		${git} -C "$NB_HOME_NOTEBOOK" remote set-url origin "${nbRemote}"
        	elif [[ -z $origin ]]; then
        		echo Adding nb remote "${nbRemote}"
        		${git} -C "$NB_HOME_NOTEBOOK" remote add origin "${nbRemote}" &&
        			${git} -C "$NB_HOME_NOTEBOOK" pull origin trunk
        	fi
        fi
      '';

    packages = with pkgs; [
      nb
      pandoc
      socat
      tig
      w3m
    ];
  };

  imports = [../helix/markdown];
}
