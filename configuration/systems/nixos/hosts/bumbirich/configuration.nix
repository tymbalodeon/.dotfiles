let
  defaultUser = import ../../../../modules/users/default-user.nix;
in {
  home-manager.users.${defaultUser.username} = import ./home.nix;

  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix
  ];

  powerManagement.enable = true;

  services = {
    auto-cpufreq = {
      enable = true;

      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };

        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };

    thermald.enable = true;
  };
}
