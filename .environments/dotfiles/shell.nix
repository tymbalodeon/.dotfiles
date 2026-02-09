{pkgs, ...}: {
  packages = with pkgs; [
    helix
    hyprls
    kdlfmt
    ormolu
    prettierd
    unixtools.column
  ];
}
