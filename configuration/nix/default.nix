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

      # TODO: disable in Home Manager since this is handled by `nh`
      gc = {
        automatic = true;
        options = "--delete-older-than 7d";
      };

      settings.experimental-features = [
        "flakes"
        "nix-command"
      ];
    }
    // optionalAttrs (hostType != "nixos") {package = pkgs.nix;};
}
