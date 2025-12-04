{pkgs, ...}: {
  packages = with pkgs; [
    hyprls
    kdlfmt
    ormolu
    prettierd
    unixtools.column
  ];
}
