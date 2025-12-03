{
  config,
  pkgs,
  ...
}: {
  home = {
    file."${config.nushell.configDirectory}/update-wallpaper.nu".source =
      ./update-wallpaper.nu;

    packages = [pkgs.swaybg];
  };
}
