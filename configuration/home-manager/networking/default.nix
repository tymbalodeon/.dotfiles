{pkgs, ...}: {
  home.packages = with pkgs; [
    arp-scan-rs
    nmap
    traceroute
    tshark
  ];
}
