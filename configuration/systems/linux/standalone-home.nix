# TODO: some of these settings are the same as elsewhere. Consolidate them and
# pull them in rather than copy them here.
{
  config,
  nixgl,
  pkgs,
  ...
}: {
  home = {
    packages = with pkgs; [
      # TODO: find a way to add this to known programs
      teams-for-linux
      xclip
      # FIXME: this doesn't work.
      # zoom-us
    ];
  };

  imports = [./home.nix];
  nixGL.packages = nixgl.packages;
  nixpkgs.config.allowUnfree = true;

  programs = {
    ghostty.package = config.lib.nixGL.wrap pkgs.ghostty;
    kitty.package = config.lib.nixGL.wrap pkgs.kitty;
  };

  targets.genericLinux.enable = true;
  xdg.mime.enable = true;
  # FIXME: get this to show up in the login screen
  # xsession.windowManager.i3.enable = true;
}
