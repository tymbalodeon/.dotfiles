{
  channel,
  hostType,
  lib,
  pkgs,
  ...
}: {
  nix = let
    inherit (lib) optionalAttrs;
  in
    {
      extraOptions = "warn-dirty = false";

      gc = {
        automatic = true;
        options = "--delete-older-than 7d";
      };

      settings.experimental-features = [
        "flakes"
        "nix-command"
      ];
    }
    // optionalAttrs (hostType != "nixos") {package = pkgs.nix;}
    // optionalAttrs (channel != "25_05") {gc.dates = "weekly";};
}
