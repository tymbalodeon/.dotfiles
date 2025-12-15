{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    (pkgs.catppuccin-sddm.override
      {
        accent = "lavender";
        flavor = "mocha";
        fontSize = "12";
      })
  ];

  services.displayManager.sddm = {
    enable = true;

    settings = {
      AutoLogin.User = config.nixos.username;

      Theme = {
        CursorSize = 16;
        CursorTheme = "Bibata-Modern-Classic";
      };
    };

    theme = "catppuccin-mocha-lavender";
    wayland.enable = true;
  };
}
