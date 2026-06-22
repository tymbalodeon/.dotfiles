_: prev: let
  mkFont = {
    name,
    sha256,
    url,
  }:
    with prev;
      stdenv.mkDerivation {
        inherit name;

        src = fetchzip {
          inherit sha256;

          stripRoot = false;
          url = "https://anrt-nancy.fr/media/pages/fonts/${url}";
        };

        installPhase = ''
          mkdir --parents $out/share/fonts/opentype/

          find . \
            -name "*.otf" \
            -not -path "./__MACOSX/" \
            -exec cp "{}" $out/share/fonts/opentype \;
        '';
      };
in
  builtins.listToAttrs (
    map
    (
      {
        name,
        sha256,
        url,
      }: {
        inherit name;

        value = mkFont {
          inherit
            name
            sha256
            url
            ;
        };
      }
    )
    (import ./anrt-fonts.nix)
  )
