{
  nbRemote,
  pkgs,
  ...
}:
# TODO: handle $VERBOSE and $DRY_RUN
# TODO: is it possible to git pull the remote notes here?
let
  git = "${pkgs.git}/bin/git";
in ''
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

  if [[ -n "${nbRemote}" ]]; then
  	origin=$(
      ${git} -C "$nb_home_notebook" remote get-url origin 2>/dev/null ||
        echo ""
    )

  	if [[ -n $origin ]] && [[ $origin != "${nbRemote}" ]]; then
  		echo Setting nb remote to "${nbRemote}"
  		${git} -C "$nb_home_notebook" remote set-url origin "${nbRemote}"
  	elif [[ -z $origin ]]; then
  		echo Adding nb remote "${nbRemote}"
  		${git} -C "$nb_home_notebook" remote add origin "${nbRemote}"
  	fi
  fi
''
