{
  config,
  pkgs,
  ...
}: let
  darkReaderID = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
  protonPassID = "ghmbeldphafepmbegfdlkpapadhbakde";
in {
  home.file.".config/BraveSoftware/Brave-Browser/Default/Preferences" = {
    force = true;
    source = config.lib.file.mkOutOfStoreSymlink builtins.toJSON {
      account_values = {
        brave = let
          startPageGUID = "485bf7d3-0215-45af-87dc-538868000510";
        in {
          default_private_search_provider_data = {
            short_name = "Startpage";
            suggestions_url = "https://www.startpage.com/cgi-bin/csuggest?query={searchTerms}&limit=10&format=json";
            synced_guid = startPageGUID;
            url = "https://www.startpage.com/do/search?q={searchTerms}&segment=startpage.brave";
          };

          default_private_search_provider_guid = startPageGUID;
        };

        extensions = {
          commands = {
            "linux:Alt+A" = {
              command_name = "addSite";
              extension = darkReaderID;
              global = false;
            };

            "linux:Alt+Shift+D" = {
              command_name = "toggle";
              extension = darkReaderID;
              global = false;
            };
          };

          pinned_extensions = [
            darkReaderID
            protonPassID
            "idfhjammokilkemckgdbjckkbgmbacne"
          ];
        };

        toolbar = {
          pinned_actions = [
            "kActionShowChromeLabs"
            "kActionShowPasswordsBubbleOrPage"
            "kActionCopyUrl"
            "kActionSendTabToSelf"
          ];
        };
      };

      webkit = {
        webprefs = {
          fonts = {
            fixed = {Zyyy = "Iosevka";};
            math = {Zyyy = "DejaVu Math TeX Gyre";};
            sansserif = {Zyyy = "Liberation Sans";};
            serif = {Zyyy = "Gentium Book";};
            standard = {Zyyy = "Sans";};
          };
        };
      };
    };
  };

  programs.brave = {
    enable = true;

    extensions = [
      {id = "bkkbcggnhapdmkeljlodobbkopceiche";}
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";}
      {id = darkReaderID;}
      {id = "gfbliohnnapiefjpjlpjnehglfpaknnc";}
      {id = protonPassID;}
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
