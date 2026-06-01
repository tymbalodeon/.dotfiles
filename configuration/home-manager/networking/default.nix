{pkgs, ...}: {
  home.packages = with pkgs; [
    arp-scan-rs
    traceroute
    tshark
  ];
}
