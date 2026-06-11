{pkgs, ...}: {
  home.packages = [pkgs.brave];

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
