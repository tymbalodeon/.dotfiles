_: prev: let
  kelmscott-mono = import ./kelmscott-mono.nix;
in
  with prev;
    stdenv.mkDerivation {
      name = kelmscott-mono.name;

      src = fetchurl {
        inherit hash url;
      };

      installPhase = ''
        mkdir --parents $out/share/fonts/opentype/
        echo $(ls)
      '';
    }
