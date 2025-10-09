{pkgs, ...}: let
  user = import ./default.nix;
in {
  services = {
    displayManager.settings.AutoLogin.User = user.username;
    mpd.musicDirectory = "/run/media/benrosen/G-DRIVE Thunderbolt 3/Music";
  };

  users.users.${user.username} = {
    description = user.name;
    extraGroups = ["networkmanager" "wheel"];
    isNormalUser = true;
    shell = pkgs.nushell;
  };
}
