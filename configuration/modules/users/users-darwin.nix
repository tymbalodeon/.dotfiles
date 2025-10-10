{
  config,
  lib,
  ...
}:
with lib; {
  config = let
    user = import ./user.nix;
    username = user.username;
  in
    mkIf config.users-darwin.enable {
      users.users.${username}.home = /Users/${username};
      system.primaryUser = username;
    };

  options.users-darwin.enable =
    mkEnableOption "enables user configuration for \"darwin\"";
}
