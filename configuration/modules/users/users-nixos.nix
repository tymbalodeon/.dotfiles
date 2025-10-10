{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = let
    user = import ./user.nix;
  in
    mkIf config.users-nixos.enable {
      services.displayManager.sddm.settings.AutoLogin.User = user.username;

      users.users.${user.username} = {
        description = user.name;
        extraGroups = ["networkmanager" "wheel"];
        isNormalUser = true;
        shell = pkgs.nushell;
      };
    };

  options.users-nixos.enable =
    mkEnableOption "enables user configuration for \"nixos\"";
}
