{
  config,
  lib,
  ...
}: {
  home.sessionVariables = {EDITOR = "hx";};

  imports = [
    ./bash
    ./json
    ./markdown
    ./nix
    ../../stylix
    ./toml
    ./txt
    ./yaml
  ];

  programs.helix = {
    defaultEditor = true;
    enable = true;

    settings =
      {
        editor = {
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
        };

        keys = let
          space = {w.S-q = ":quit!";};
        in {
          normal = {
            inherit space;

            C-g = [":reset-diff-change"];
            C-j = ["extend_to_line_bounds" "delete_selection" "paste_after"];

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
      // lib.optionalAttrs (config.stylix.theme == "catppuccin-mocha") {
        theme = "catppuccin_mocha";
      };
  };

  stylix.targets.helix.enable = !(config.stylix.theme == "catppuccin-mocha");
}
