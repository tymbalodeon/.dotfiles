{pkgs, ...}: {
  # TODO: switch this to `dysk` when available (or make it available)
  home.packages = [pkgs.duf];

  imports = [
    ../../home.nix
    {programs.nushell.configDirectory = "Library/Application Support/nushell";}
  ];
}
