# TODO: remove this file!
{
  config,
  lib,
  ...
}:
with lib; {
  config = mkIf config.users-linux.enable {
    homeDirectory = let
      username = import ./username.nix;
    in
      /home/${username};
  };

  options.users-linux.enable =
    mkEnableOption "enables user configuration for \"linux\"";
}
