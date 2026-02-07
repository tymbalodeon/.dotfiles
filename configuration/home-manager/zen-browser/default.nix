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

          ExtensionSettings = builtins.listToAttrs (map (
              shortId: {
                name =
                  (builtins.fromJSON
                    (builtins.readFile (builtins.fetchurl
                      {
                        url = "https://addons.mozilla.org/api/v5/addons/addon/${shortId}/";
                      }))).guid;

                value = {
                  installation_mode = "normal_installed";
                  install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
                };
              }
            ) [
              "catppuccin-mocha-lavender-git"
              "darkreader"
              "proton-pass"
              "refined-github-"
              "subscription-feed-filter"
              "tridactyl-vim"
              "undistracted-main"
            ]);

          SearchEngines = {
            Add = [
              {
                Alias = "@np";
                IconURL = "https://wiki.nixos.org/favicon.ico";
                Name = "nixpkgs";
                URLTemplate = "https://search.nixos.org/packages?query={searchTerms}";
              }

              {
                Alias = "@no";
                IconURL = "https://wiki.nixos.org/favicon.ico";
                Name = "NixOS options";
                URLTemplate = "https://search.nixos.org/options?query={searchTerms}";
              }

              {
                Alias = "@nw";
                IconURL = "https://wiki.nixos.org/favicon.ico";
                Name = "NixOS Wiki";
                URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
              }

              {
                Alias = "@ng";
                IconURL = "https://noogle.dev/favicon.ico";
                Name = "noogle";
                URLTemplate = "https://noogle.dev/q?term={searchTerms}";
              }
            ];

            Default = "ddg";
          };
        };
      }
    )
  ];
}
