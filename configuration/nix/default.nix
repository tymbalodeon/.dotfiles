{
  hostType,
  lib,
  pkgs,
  ...
}: {
  nix =
    {
      extraOptions = "warn-dirty = false";

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      settings.experimental-features = [
        "flakes"
        "nix-command"
      ];
    }
    // lib.optionalAttrs (hostType != "nixos") {package = pkgs.nix;};
}
