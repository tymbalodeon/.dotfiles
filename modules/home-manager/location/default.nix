{config, ...}: {
  imports = [../shell/nushell];

  nushell.extraScripts = [
    {
      name = "location";

      text =
        (builtins.readFile ./location.nu)
        + ''

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
  ];

  sops.secrets."location/latitude" = {};
  sops.secrets."location/longitude" = {};
}
