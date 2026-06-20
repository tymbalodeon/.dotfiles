{pkgs, ...}: let
  mkFont = {
    fileGlob,
    name,
    sha256,
    url,
  }:
    with pkgs;
      stdenv.mkDerivation {
        name = name;

        src = fetchzip {
          inherit sha256;
          stripRoot = false;
          url = "https://anrt-nancy.fr/media/pages/fonts/${url}";
        };

        installPhase = ''
          mkdir --parents $out/share/fonts/opentype/
          cp "${fileGlob}" $out/share/fonts/opentype/
        '';
      };

  baskervville = mkFont {
    fileGlob = "baskervville-regular/otf/Baskervville-Regular.otf";
    name = "baskervville";
    sha256 = "sha256-ppQYjkyZRJctxk1pYHaj71NkaVWyiQTk8WZHxAQyvm8=";
    url = "baskervville/46f1017574-1678381500/baskervville-regular.zip";
  };

  baskervville-italic = mkFont {
    fileGlob = "baskervville-italic/otf/Baskervville-Italic.otf";
    name = "baskervville-italic";
    sha256 = "sha256-2MYnAtvVrlLLFDZQ6H5GIJTkZsg+yQOqurNW+kRE/mU=";
    url = "baskervville/271ffa28c0-1678381500/baskervville-italic.zip";
  };

  durandus = mkFont {
    fileGlob = "gotico-antiqua_Durandus-118G/Fust&Schoeffer-Durandus-GoticoAntiqua118G.otf";
    name = "durandus";
    sha256 = "sha256-Oquj8QP+VPfViPlQFZasySCwKtfiyztNo6w4lq3tUZk=";
    url = "gotico-antiqua/0d198ed659-1678381500/gotico-antiqua_durandus-118g.zip";
  };

  subiaco = mkFont {
    fileGlob = "gotico-antiqua_Sweynheim-Pannartz-120R/Sweynheim&Pannartz-Subiaco-ProtoRoman120R.otf";
    name = "subiaco";
    sha256 = "sha256-0u3jvB7+WqFwBfMrCOPSMNAN5QOxVO9CXUNNZKZm2eM=";
    url = "gotico-antiqua/c3eb075c42-1678381560/gotico-antiqua_sweynheim-pannartz-120r.zip";
  };
in {
  home.packages = [
    baskervville
    baskervville-italic
    durandus
    subiaco
  ];
}
