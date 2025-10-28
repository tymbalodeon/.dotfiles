{
  imports = [
    ../common/home.nix
    ../../modules/brave
    ../../modules/firefox
    ../../modules/ghostty
  ];

  xdg.mimeApps = {
    defaultApplications."application/pdf" = ["org.pwmt.zathura.desktop"];
    enable = true;
  };
}
