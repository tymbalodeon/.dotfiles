{
  config,
  lib,
  pkgs,
  ...
}: let
  adBlockID = "gighmmpiobklfepjocnamgkkbiglidom";
  darkReaderID = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
  enhancerForYouTubeID = "ponfpcnoihfmfllpaingbgckeeldkhle";
  protonPassID = "ghmbeldphafepmbegfdlkpapadhbakde";
  refinedGitHubID = "hlepfoohegkhhmjieoechaddaejaokhf";
  subscriptionFeedFilterForYouTubeID = "jpdngflnlekafjhdlcnijphhcmeibdoa";
  surfingKeysID = "gfbliohnnapiefjpjlpjnehglfpaknnc";
  uBlockOriginID = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
  unDistractedID = "pjjgklgkfeoeiebjogplpnibpfnffkng";
  youTubeAntiTranslateID = "ndpmhjnlfkgfalaieeneneenijondgag";
  youTubeBlackAndWhiteFilterID = "idfhjammokilkemckgdbjckkbgmbacne";
in {
  config = let
    cfg = config.browser;
  in
    lib.mkIf cfg.enable {
      home.activation.browser = let
        preferences = let
          startpageGUID = "485bf7d3-0215-45af-87dc-538868000510";
        in {
          bookmark_bar = {
            show_on_all_tabs = false;
            show_tab_groups = true;
          };

          brave = {
            accelerators = {
              "33000" = [
                "BrowserBack"
                "Alt+ArrowLeft"
                "AltGr+ArrowLeft"
                "Control+BracketLeft"
              ];

              "33001" = [
                "BrowserForward"
                "Alt+ArrowRight"
                "AltGr+ArrowRight"
                "Control+BracketRight"
              ];
            };

            ai_chat = {
              "autocomplete_provider_enabled" = false;
              "context_menu_enabled" = false;
              "show_toolbar_button" = false;
              "tab_organization_enabled" = false;
            };

            always_show_bookmark_bar_on_ntp = false;

            autocomplete_enabled = true;
            default_private_search_provider_guid = startpageGUID;
            enable_window_closing_confirm = false;
            has_seen_welcome_page = true;
            location_bar_is_wide = true;
            new_tab_page.shows_options = 2;
            rewards.show_brave_rewards_button_in_location_bar = false;
            show_side_panel_button = false;
            top_site_suggestions_enabled = false;
            wallet.show_wallet_icon_on_toolbar = false;
            web_view_rounded_corners = false;
          };

          browser.show_home_button = false;
          default_search_provider.guid = startpageGUID;

          default_search_provider_data.template_url_data = {
            favicon_url = "https://cdn.startpage.com/sp/cdn/favicons/favicon-32x32-gradient.png";
            id = "7";
            input_encodings = ["UTF-8"];
            is_active = 1;
            keyword = ":sp";
            short_name = "Startpage";
            suggestions_url = "https://www.startpage.com/cgi-bin/csuggest?query={searchTerms}&limit=10&format=json";
            suggestions_url_post_params = "";
            synced_guid = startpageGUID;
            url = "https://www.startpage.com/do/search?q={searchTerms}&segment=startpage.brave";
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

            pinned_extensions =
              [
                adBlockID
                darkReaderID
                protonPassID
                surfingKeysID
                unDistractedID
                youTubeBlackAndWhiteFilterID
              ]
              ++ cfg.extraExtensionIDs;

            settings = {
              ${adBlockID}.incognito = true;
              ${darkReaderID}.incognito = true;
              ${enhancerForYouTubeID}.incognito = true;
              ${protonPassID}.incognito = true;
              ${refinedGitHubID}.incognito = true;
              ${subscriptionFeedFilterForYouTubeID}.incognito = true;
              ${surfingKeysID}.incognito = true;
              ${uBlockOriginID}.incognito = true;
              ${unDistractedID}.incognito = true;
              ${youTubeAntiTranslateID}.incognito = true;
              ${youTubeBlackAndWhiteFilterID}.incognito = true;
            };
          };

          search.suggest_enabled = false;
          session.restore_on_startup = 5;

          sync = {
            apps = true;
            autofill = true;
            bookmarks = true;
            extensions = true;
            keep_everything_synced = true;
            passwords = true;
            payments = true;
            preferences = true;
            reading_list = true;
            saved_tab_groups = true;
            tabs = true;
            themes = true;
            typed_urls = true;
          };

          tab_groups.deletion.skip_dialog_on_close_tab = true;

          toolbar.pinned_actions = [
            "kActionShowChromeLabs"
            "kActionShowPasswordsBubbleOrPage"
            "kActionCopyUrl"
            "kActionSendTabToSelf"
          ];

          webkit.webprefs.fonts = {
            fixed = {Zyyy = "Iosevka";};
            math = {Zyyy = "DejaVu Math TeX Gyre";};
            sansserif = {Zyyy = "Liberation Sans";};
            serif = {Zyyy = "Gentium Book";};
            standard = {Zyyy = "Sans";};
          };
        };
      in let
        script =
          pkgs.writeScript "activate-browser"
          # nushell
          (
            ''
              def brave-secrets-base [] {
                $env.HOME
                | path join .config/sops-nix/secrets/BraveSoftware/Brave-Browser/Default/Preferences
              }

              def open-secret [path: string] {
                try {
                  open (
                    brave-secrets-base
                    | path join $path
                  )
                }
              }

              def brave-sync-v2-seed [] {
                open-secret brave_sync_v2/seed
              }

              def sync-encryption_bootstrap_token_per_account-key [] {
                open-secret sync/encryption_bootstrap_token_per_account/key
              }

              def sync-encryption_bootstrap_token_per_account-value [] {
                open-secret sync/encryption_bootstrap_token_per_account/value
              }

            ''
            + builtins.readFile ./home-activation.nu
          );
      in
        lib.hm.dag.entryAfter ["writeBoundary"] ''
          run ${lib.getExe pkgs.nushell} ${script} '${builtins.toJSON preferences}' \
          | ${lib.getExe pkgs.jq} --compact-output . \
          > ~/.config/BraveSoftware/Brave-Browser/Default/Preferences
        '';

      programs.brave = {
        enable = true;

        extensions =
          [
            {id = adBlockID;}
            {id = darkReaderID;}
            {id = enhancerForYouTubeID;}
            {id = protonPassID;}
            {id = refinedGitHubID;}
            {id = subscriptionFeedFilterForYouTubeID;}
            {id = surfingKeysID;}
            {id = uBlockOriginID;}
            {id = unDistractedID;}
            {id = youTubeAntiTranslateID;}
            {id = youTubeBlackAndWhiteFilterID;}
          ]
          ++ (map (id: {inherit id;}) cfg.extraExtensionIDs);
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

      sops.secrets = {
        "BraveSoftware/Brave-Browser/Default/Preferences/brave_sync_v2/seed" = {};
        "BraveSoftware/Brave-Browser/Default/Preferences/sync/encryption_bootstrap_token_per_account/key" = {};
        "BraveSoftware/Brave-Browser/Default/Preferences/sync/encryption_bootstrap_token_per_account/value" = {};
      };
    };

  imports = [
    ./browsh
    ./chawan
    ../secrets
    ./w3m
  ];

  options.browser = let
    inherit (lib) mkEnableOption mkOption types;
    inherit (types) listOf str;
  in {
    enable = mkEnableOption "Browser";

    extraExtensionIDs = mkOption {
      default = [];
      type = listOf str;
    };
  };
}
