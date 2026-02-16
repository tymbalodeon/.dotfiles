{pkgs, ...}: {
  programs.chromium = {
    enable = true;

    extensions = map (extension: {inherit (extension) id;}) [
      {
        name = "adguard-adblocker";
        id = "bgnkhhnnamicmpeenaelnjfhikgbkllg";
      }

      {
        name = "darkreader";
        id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
      }

      {
        name = "proton-pass";
        id = "ghmbeldphafepmbegfdlkpapadhbakde";
      }

      {
        name = "refined-github-";
        id = "hlepfoohegkhhmjieoechaddaejaokhf";
      }

      {
        name = "subscription-feed-filter";
        id = "jpdngflnlekafjhdlcnijphhcmeibdoa";
      }

      {
        name = "surfingkeys_ff";
        id = "gfbliohnnapiefjpjlpjnehglfpaknnc";
      }

      {
        name = "undistracted-main";
        id = "pjjgklgkfeoeiebjogplpnibpfnffkng";
      }
    ];

    package = pkgs.brave;
  };
}
