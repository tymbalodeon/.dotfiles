{
  config,
  lib,
}:
with lib; {
  config = mkIf config.users.linux.enable {
    homeDirectory = let
      username = (import ./default.nix).username;
    in
      /home/${username};
  };

  options.users.linux.enable =
    mkEnableOption "enables user configuration for \"linux\"";
}
