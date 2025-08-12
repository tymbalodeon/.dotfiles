{
  lib,
  pkgs,
  ...
}: {
  home.activation.nb = lib.hm.dag.entryAfter ["writeBoundary"] (
    import ./entry-after.nix {
      inherit pkgs;
      nbRemote = (import ../users/default-user.nix).nbRemotePersonal or "";
    }
  );
}
