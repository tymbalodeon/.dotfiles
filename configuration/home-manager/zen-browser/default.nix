{
  pkgs,
  zen-browser,
  ...
}: {
  home.packages = [
    (
      pkgs.wrapFirefox
      zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped
      {
        extraPolicies = {
          DisableTelemetry = true;

          ExtensionSettings = builtins.listToAttrs (
            builtins.fromJSON (builtins.readFile ./extensions.json)
          );

          SearchEngines = {
            Add = [
              {
                Alias = "@hm";
                IconURL = "https://home-manager-options.extranix.com/favicon.ico";
                Name = "Home-Manager options";
                URLTemplate = "https://home-manager-options.extranix.com/favicon.ico?release=master&query=&{searchTerms}";
              }

              {
                Alias = "@ng";
                IconURL = "https://noogle.dev/favicon.ico";
                Name = "noogle";
                URLTemplate = "https://noogle.dev/q?term={searchTerms}";
              }

              {
                Alias = "@no";
                IconURL = "https://wiki.nixos.org/favicon.ico";
                Name = "NixOS options";
                URLTemplate = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
              }

              {
                Alias = "@np";
                IconURL = "https://wiki.nixos.org/favicon.ico";
                Name = "nixpkgs";
                URLTemplate = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
              }

              {
                Alias = "@nw";
                IconURL = "https://wiki.nixos.org/favicon.ico";
                Name = "NixOS Wiki";
                URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
              }
            ];

            Default = "ddg";
          };
        };
      }
    )
  ];

  xdg.mimeApps = {
    defaultApplications = let
      zenBrowser = "zen.desktop";
    in {
      "text/html" = zenBrowser;
      "x-scheme-handler/about" = zenBrowser;
      "x-scheme-handler/http" = zenBrowser;
      "x-scheme-handler/https" = zenBrowser;
      "x-scheme-handler/unknown" = zenBrowser;
    };

    enable = true;
  };
}
