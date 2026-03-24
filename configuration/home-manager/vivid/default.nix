{
  hostType,
  lib,
  ...
}: {
  programs.vivid =
    {
      enableBashIntegration = true;
      enableNushellIntegration = true;
      enable = true;
    }
    // lib.optionalAttrs (hostType == "home-manager") {
      activeTheme = "catppuccin-mocha";
    };
}
