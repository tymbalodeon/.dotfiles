{pkgs, ...}: {
  services.swayidle = let
    niri = "${pkgs.niri}/bin/niri";
  in {
    enable = true;

    timeouts = [
      {
        command = "${pkgs.nushell}/bin/nu ${../monitors/brightness.nu} set min";
        timeout = 290;
      }

      {
        command = "${niri} msg action power-off-monitors";
        resumeCommand = "${niri} msg action power-on-monitors";
        timeout = 300;
      }

      {
        command = "${pkgs.systemd}/bin/systemctl suspend";
        timeout = 600;
      }
    ];
  };
}
