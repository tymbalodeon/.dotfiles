{pkgs, ...}: {
  packages = with pkgs; [
    hyprls
    kdlfmt
    prettierd
    unixtools.column
  ];
}
