{pkgs, ...}: {
  home.packages = with pkgs; [
    proton-pass
    proton-pass-cli
  ];

  services = {
    gnome-keyring.enable = true;
    proton-pass-agent.enable = true;
  };
}
