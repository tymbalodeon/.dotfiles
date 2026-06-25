{
  hostType,
  lib,
  ...
}: {
  programs = {
    vivid =
      {
        enableNushellIntegration = true;
        enable = true;
      }
      // lib.optionalAttrs (hostType == "home-manager") {
        activeTheme = "catppuccin-mocha";
      };
  };
}
