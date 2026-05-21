{pkgs, ...}: {
  home.packages = with pkgs; [
    traceroute
    tshark
  ];
}
