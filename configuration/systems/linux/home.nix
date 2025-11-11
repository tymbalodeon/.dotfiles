{
  imports = [
    ../common/home.nix
    ../../modules/brave
    ../../modules/firefox
    ../../modules/ghostty
  ];

  xdg = {
    configFile."mimeapps.list".force = true;

    mimeApps = {
      defaultApplications."application/pdf" = ["org.pwmt.zathura.desktop"];
      enable = true;
    };
  };
}
