{pkgs, ...}: {
  home = rec {
    homeDirectory =
      if pkgs.stdenv.isLinux
      then /home/${username}
      else /Users/${username};

    username = "benrosen";
  };
}
