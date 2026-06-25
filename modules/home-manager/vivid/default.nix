{
  hostType,
  lib,
  ...
}: {
  programs = {
    vivid =
      {
        enableNushellIntegration = false;
        enable = true;
      }
      // lib.optionalAttrs (hostType == "home-manager") {
        activeTheme = "catppuccin-mocha";
      };
  };
}
