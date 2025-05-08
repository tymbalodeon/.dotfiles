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
        NB_DIR="$HOME/.nb/home"

        if [[ ! -d $NB_DIR ]]; then
        	mkdir --parents $NB_DIR
        elif [[ -n "${nbRemote}" ]] &&
        	! eval "${git} -C $NB_DIR remote get-url origin"; then
        	${git} -C $NB_DIR remote add origin "${nbRemote}"
        elif [[ $(${git} -C $NB_DIR remote get-url origin) != "${nbRemote}" ]]; then
        	${git} -C $NB_DIR remote set-url origin "${nbRemote}"
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
