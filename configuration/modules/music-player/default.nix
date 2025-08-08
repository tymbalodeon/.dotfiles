{pkgs, ...}: {
  home.packages = with pkgs;
    [
      mpd
    ]
    ++ (
      if stdenv.isLinux
      then [rmpc]
      else if stdenv.isDarwin
      then [mpc ncmpcpp]
      else []
    );
}
