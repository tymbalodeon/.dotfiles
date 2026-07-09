{pkgs, ...}: {
  home.packages = with pkgs; [
    proton-pass
    proton-pass-cli
  ];

  # FIXME
  # services.proton-pass-agent.enable = true;
}
