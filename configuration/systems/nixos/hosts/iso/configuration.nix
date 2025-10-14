{
  modulesPath,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    brave
    direnv
    nix-direnv
    git
    helix
    just
    (
      writeShellScriptBin "install-dotfiles" (builtins.readFile ./install-dotfiles)
    )
  ];

  imports = let
    installer = "graphical-calamares-gnome";
  in [
    "${modulesPath}/installer/cd-dvd/installation-cd-${installer}.nix"
  ];

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
  };

  nix.settings.experimental-features = [
    "flakes"
    "nix-command"
  ];
}
