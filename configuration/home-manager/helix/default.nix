{
  base16-helix,
  config,
  hostType,
  lib,
  ...
}: {
  config = let
    cfg = config.helix;
  in
    {
      assertions = [
        {
          assertion = hostType != "home-manager";
          message = "Home Manager systems do not use Stylix.";
        }
      ];

      home.sessionVariables = {EDITOR = "hx";};

      programs.helix = {
        defaultEditor = true;
        enable = true;

        settings = let
          inherit (lib) optionalAttrs;
        in
          {
            editor =
              {
                bufferline = "multiple";
                color-modes = true;
                cursorline = true;

                cursor-shape = {
                  insert = "bar";
                  select = "underline";
                };

                end-of-line-diagnostics = "hint";
                file-picker.hidden = false;
                indent-guides.render = true;
                inline-diagnostics.cursor-line = "warning";
                mouse = false;
                shell = ["nu" "-c"];

                statusline = {
                  center = [
                    "read-only-indicator"
                    "file-name"
                    "file-modification-indicator"
                    "spacer"
                    "file-type"
                  ];

                  left = ["mode" "spinner"];

                  mode = {
                    insert = "INSERT";
                    normal = "NORMAL";
                    select = "SELECT";
                  };

                  right = [
                    "diagnostics"
                    "selections"
                    "primary-selection-length"
                    "register"
                    "position"
                    "total-line-numbers"
                    "position-percentage"
                    "file-encoding"
                  ];
                };

                whitespace.render = {
                  space = "all";
                  tab = "all";
                };
              }
              // optionalAttrs (hostType == "nixos") {
                clipboard-provider = "wayland";
              };

            keys = let
              space = {w.S-q = ":quit!";};
            in {
              normal = {
                inherit space;

                C-g = [":reset-diff-change"];

                C-j = [
                  "extend_to_line_bounds"
                  "delete_selection"
                  "paste_after"
                ];

                C-k = [
                  "extend_to_line_bounds"
                  "delete_selection"
                  "move_line_up"
                  "paste_before"
                ];

                esc = ["collapse_selection" "keep_primary_selection"];
                X = ["extend_line_up" "extend_to_line_bounds"];
              };

              select = {
                inherit space;

                X = ["extend_line_up" "extend_to_line_bounds"];
              };
            };
          }
          // lib.optionalAttrs (hostType == "home-manager") {
            theme = cfg.theme;
          }
          // lib.optionalAttrs (
            hostType
            != "home-manager"
            && cfg.stylix.enable
            && !cfg.useDefaultStylixTheme
          ) {
            theme = "stylix-modified";
          };

        themes.stylix-modified = let
          stylixTheme = fromTOML (
            builtins.readFile
            "${base16-helix}/base16-${config.stylix.theme}.toml"
          );
        in
          stylixTheme
          // {
            "ui.cursor.primary" = {
              bg = "base0E";
              fg = "base01";
            };

            "ui.gutter.selected" = {bg = "base01";};
            "ui.virtual.indent-guide" = "base01";
            "ui.virtual.whitespace" = "base01";
          };
      };
    }
    // lib.optionalAttrs (hostType != "home-manager") {
      stylix.targets.helix.enable = cfg.stylix.enable && cfg.useDefaultStylixTheme;
    };

  imports =
    [
      ./bash
      ./json
      ./markdown
      ./nix
      ./toml
      ./txt
      ./yaml
    ]
    ++ (
      if hostType == "home-manager"
      then []
      else [
        ../../stylix
      ]
    );

  options.helix = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    stylix.enable = mkOption {
      default = true;
      type = types.bool;
    };

    theme = mkOption {
      default = "catppuccin_mocha";
      type = types.str;
    };

    useDefaultStylixTheme =
      mkEnableOption "Use the default stylix theme, if using stylix";
  };
}
