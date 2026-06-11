{pkgs, ...}: {
  programs.brave = {
    enable = true;

    extensions = [
      {id = "bkkbcggnhapdmkeljlodobbkopceiche";}
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";}
      {id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";}
      {id = "gfbliohnnapiefjpjlpjnehglfpaknnc";}
      {id = "ghmbeldphafepmbegfdlkpapadhbakde";}
      {id = "gighmmpiobklfepjocnamgkkbiglidom";}
      {id = "hlepfoohegkhhmjieoechaddaejaokhf";}
      {id = "idfhjammokilkemckgdbjckkbgmbacne";}
      {id = "jpdngflnlekafjhdlcnijphhcmeibdoa";}
      {id = "ndpmhjnlfkgfalaieeneneenijondgag";}
      {id = "pjjgklgkfeoeiebjogplpnibpfnffkng";}
      {id = "ponfpcnoihfmfllpaingbgckeeldkhle";}
    ];
  };

  xdg = {
    desktopEntries = {
      brave-browser-incognito = {
        categories = [
          "Network"
          "WebBrowser"
        ];

        exec = "${pkgs.brave}/bin/brave --incognito %U";
        genericName = "Web Browser";
        icon = "brave-browser";
        name = "Brave (Incognito)";

        mimeType = [
          "text/html"
          "text/xml"
        ];

        terminal = false;
      };
    };

    mimeApps = {
      enable = true;

      defaultApplications = {
        "text/html" = "brave-browser.desktop";
        "x-scheme-handler/about" = "brave-browser.desktop";
        "x-scheme-handler/http" = "brave-browser.desktop";
        "x-scheme-handler/https" = "brave-browser.desktop";
        "x-scheme-handler/unknown" = "brave-browser.desktop";
      };
    };
  };
}
