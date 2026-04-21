{
  hostType,
  lib,
  ...
}: {
  programs = {
    nushell.extraConfig = ''
      # FIXME: only necessary because stylix theme is not found when launching a
      # new kitty window from a direnv subdirectory
      try {
        $env.LS_COLORS = (vivid generate stylix)
      } catch {
        let xdg_state_home = try {
          $env.XDG_STATE_HOME
        } catch {
          $env.HOME
          | path join .local/state
        }

        let ls_colors_file = ($xdg_state_home | path join ls-colors)

        if ($ls_colors_file | path exists) {
          let colors = (open $ls_colors_file)

          if ($colors | is-not-empty) {
            $env.LS_COLORS = $colors
          }
        }
      }
    '';

    vivid =
      {
        # FIXME: see above note in nushell.extraConfig
        enableBashIntegration = false;
        enableNushellIntegration = false;
        enable = true;
      }
      // lib.optionalAttrs (hostType == "home-manager") {
        activeTheme = "catppuccin-mocha";
      };
  };
}
