{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    moon-phases
    weather-icons
    wego
  ];

  imports = [
    ../secrets
    ../shell/nushell
  ];

  nushell.extraScripts = [
    {
      name = "openweathermap-api-key";

      text = ''
        def openweathermap-api-key [] {
          open --raw ${config.sops.secrets."openweathermap/api-key".path}        
        }
      '';
    }

    {
      includes = ["location"];
      source = ./weather.nu;
    }
  ];

  sops.secrets."openweathermap/api-key" = {};
}
