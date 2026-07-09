{pkgs, ...}: {
  home.packages = with pkgs; [
    proton-vpn
    proton-vpn-cli
  ];
}
