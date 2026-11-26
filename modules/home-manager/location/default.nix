{config, ...}: {
  imports = [../shell/nushell];

  nushell.extraScripts = [
    {
      name = "location";

      text =
        (builtins.readFile ./location.nu)
        + ''

          def "geocode-maps-co-api-key" [] {
            open "${config.sops.secrets."geocode.maps.co/api-key".path}"
          }

          def "location home coordinates" [] {
            $"(location home latitude),(location home longitude)"
          }

          def "location home latitude" [] {
            open "${config.sops.secrets."location/latitude".path}"
          }

          def "location home longitude" [] {
            open "${config.sops.secrets."location/longitude".path}"
          }
        '';
    }

    {
      includes = ["astro" "weather"];
      name = "update-location-data";
      source = ./update-location-data.nu;
    }
  ];

  sops.secrets."geocode.maps.co/api-key" = {};
  sops.secrets."location/latitude" = {};
  sops.secrets."location/longitude" = {};
}
