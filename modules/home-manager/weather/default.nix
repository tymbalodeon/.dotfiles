{config, ...}: {
  imports = [
    ../secrets
    ../shell/nushell
  ];

  nushell.extraScripts = [
    {
      name = "freeastroapi-api-key";

      text = ''
        def freeastroapi-api-key [] {
          open ${config.sops.secrets."freeastroapi/api-key".path}        
        }
      '';
    }

    {
      name = "openweathermap-api-key";

      text = ''
        def openweathermap-api-key [] {
          open ${config.sops.secrets."openweathermap/api-key".path}        
        }
      '';
    }

    {
      includes = ["location"];
      source = ./weather.nu;
    }

    {
      includes = ["location"];
      source = ./moon.nu;
    }
  ];

  sops.secrets."openweathermap/api-key" = {};
  sops.secrets."freeastroapi/api-key" = {};
}
