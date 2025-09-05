{pkgs, ...}: {
  packages = with pkgs; [
    hyprls
    prettierd
    unixtools.column
  ];
}
