{
  config,
  lib,
}:
with lib; {
  config = let
    username = (import ./default.nix).username;
  in
    mkIf config.users.darwin.enable rec {
      homeDirectory = /Users/${username};
      users.users.${username}.home = homeDirectory;
      system.primaryUser = username;
    };

  options.users.darwin.enable =
    mkEnableOption "enables user configuration for \"darwin\"";
}
