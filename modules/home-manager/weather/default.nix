{pkgs, ...}: {
  home.packages = with pkgs; [
    moon-phases
    weather-icons
    wego
  ];
}
