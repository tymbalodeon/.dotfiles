{pkgs, ...}: {
  systemd.user.services.maestral = let
    maestral = "${pkgs.maestral}/bin/maestral";
  in {
    description = "Maestral daemon";
    enable = true;
    preStop = "exec ${maestral} stop";
    script = "exec ${maestral} start --foreground";

    serviceConfig = {
      NotifyAccess = "all";
      PrivateTmp = true;
      ProtectSystem = "full";
      Restart = "always";
      Type = "notify";
      WatchdogSec = "30s";
    };

    unitConfig.ConditionUser = "!@system";
    wantedBy = ["default.target"];
  };
}
