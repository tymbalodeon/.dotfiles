_: prev: let
  inherit
    (import ./kelmscott-mono.nix)
    hash
    name
    owner
    repo
    rev
    ;
in
  with prev;
    stdenv.mkDerivation {
      inherit name;

      src = pkgs.fetchFromGitHub {
        inherit
          hash
          owner
          repo
          rev
          ;
      };

      installPhase = ''
        mkdir --parents $out/share/fonts/opentype/
        echo $(ls ${src})
      '';
    }
