{
  lib,
  pkgs,
  ...
}: let
  adBlockID = "gighmmpiobklfepjocnamgkkbiglidom";
  darkReaderID = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
  enhancerForYouTubeID = "ponfpcnoihfmfllpaingbgckeeldkhle";
  popUpBlockerID = "bkkbcggnhapdmkeljlodobbkopceiche";
  protonPassID = "ghmbeldphafepmbegfdlkpapadhbakde";
  refinedGitHubID = "hlepfoohegkhhmjieoechaddaejaokhf";
  subscriptionFeedFilterForYouTubeID = "jpdngflnlekafjhdlcnijphhcmeibdoa";
  surfingKeysID = "gfbliohnnapiefjpjlpjnehglfpaknnc";
  uBlockOriginID = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
  unDistractedID = "pjjgklgkfeoeiebjogplpnibpfnffkng";
  youTubeAntiTranslateID = "ndpmhjnlfkgfalaieeneneenijondgag";
  youTubeBlackAndWhiteFilterID = "idfhjammokilkemckgdbjckkbgmbacne";
in {
  home.activation.brave = let
    # TODO: see brave://settings/system/shortcuts and brave.accelerators
    preferences = {
      bookmark_bar = {
        show_on_all_tabs = false;
        show_tab_groups = true;
      };

      brave = {
        ai_chat = {
          "autocomplete_provider_enabled" = false;
          "context_menu_enabled" = false;
          "show_toolbar_button" = false;
          "tab_organization_enabled" = false;
        };

        always_show_bookmark_bar_on_ntp = false;

        autocomplete_enabled = true;
        default_private_search_provider_guid = "485bf7d3-0215-45af-87dc-538868000510";
        enable_window_closing_confirm = false;
        has_seen_welcome_page = true;
        location_bar_is_wide = true;
        show_side_panel_button = false;
        top_site_suggestions_enabled = false;
        wallet.show_wallet_icon_on_toolbar = false;
        web_view_rounded_corners = false;
      };

      browser.show_home_button = false;

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
          surfingKeysID
          unDistractedID
          youTubeBlackAndWhiteFilterID
        ];
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
        themes = false;
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
  in
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo '${builtins.toJSON preferences}' \
      | ${lib.getExe pkgs.jq} --compact-output . \
      > ~/.config/BraveSoftware/Brave-Browser/Default/Preferences
    '';

  programs.brave = {
    enable = true;

    extensions = [
      {id = adBlockID;}
      {id = darkReaderID;}
      {id = enhancerForYouTubeID;}
      {id = popUpBlockerID;}
      {id = protonPassID;}
      {id = refinedGitHubID;}
      {id = subscriptionFeedFilterForYouTubeID;}
      {id = surfingKeysID;}
      {id = uBlockOriginID;}
      {id = unDistractedID;}
      {id = youTubeAntiTranslateID;}
      {id = youTubeBlackAndWhiteFilterID;}
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
