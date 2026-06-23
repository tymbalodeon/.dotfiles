[
  (
    _: prev: let
      mkFont = {
        dontUnpack,
        name,
        sha256,
        url,
      }:
        with prev;
          stdenv.mkDerivation {
            inherit dontUnpack name;

            installPhase =
              ''
                mkdir --parents $out/share/fonts/opentype/
              ''
              + (
                if dontUnpack
                then ''
                  cp $src $out/share/fonts/opentype
                ''
                else ''
                  find . \
                    -name "*.otf" \
                    -not -path "./__MACOSX" \
                    -exec cp "{}" $out/share/fonts/opentype \;
                ''
              );

            src =
              if dontUnpack
              then
                fetchurl {
                  inherit url;

                  hash = sha256;
                }
              else
                fetchzip {
                  inherit sha256 url;

                  stripRoot = false;
                };
          };
    in
      builtins.listToAttrs (
        map
        (
          {
            dontUnpack,
            name,
            sha256,
            url,
          }: {
            inherit name;

            value = mkFont {
              inherit
                dontUnpack
                name
                sha256
                url
                ;
            };
          }
        )
        (import ./fonts.nix)
      )
  )
]
