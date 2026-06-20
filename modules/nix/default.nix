{
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

      settings.experimental-features = [
        "flakes"
        "nix-command"
      ];
    }
    // optionalAttrs (hostType != "nixos") {package = pkgs.nix;};
}
