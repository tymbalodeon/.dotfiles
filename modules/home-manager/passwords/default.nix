{pkgs, ...}: {
  home.packages = with pkgs; [
    proton-pass
    proton-pass-cli
  ];

  programs.keepassxc.enable = true;
  services.proton-pass-agent.enable = true;
}
