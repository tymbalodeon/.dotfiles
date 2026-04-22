{pkgs, ...}: {
  packages = with pkgs; [
    helix
    hyprls
    kdlfmt
    nh
    ormolu
    prettierd
    unixtools.column
  ];
}
