{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      proton-pass
      proton-pass-cli
    ];

    sessionVariables.PROTON_PASS_LINUX_KEYRING = "dbus";
  };

  services = {
    gnome-keyring.enable = true;
    proton-pass-agent.enable = true;
  };
}
