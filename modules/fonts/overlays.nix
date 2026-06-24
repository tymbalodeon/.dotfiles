[
  (
    _: prev: let
      mkFont = {
        dontUnpack,
        name,
        sha256,
        ttf,
        url,
      }:
        with prev;
          stdenv.mkDerivation {
            inherit dontUnpack name;

            installPhase = let
              outputDirectory =
                if ttf
                then "truetype"
                else "opentype";
            in
              ''
                mkdir --parents $out/share/fonts/${outputDirectory}/
              ''
              + (
                if dontUnpack
                then ''
                  cp $src $out/share/fonts/${outputDirectory}/
                ''
                else let
                  fileType =
                    if ttf
                    then "ttf"
                    else "otf";
                in ''
                  find . \
                    -name "*.${fileType}" \
                    -not -path "./__MACOSX" \
                    -exec cp "{}" $out/share/fonts/${outputDirectory}/ \;
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
            dontUnpack ? false,
            name,
            sha256,
            ttf ? false,
            url,
          }: {
            inherit name;

            value = mkFont {
              inherit
                dontUnpack
                name
                sha256
                ttf
                url
                ;
            };
          }
        )
        (import ./fonts.nix)
      )
  )
]
