{config, ...}: {
  imports = [
    ../secrets
    ../shell/nushell
  ];

  nushell.extraScripts = [
    {
      name = "apiverve-api-key";

      text = ''
        def apiverve-api-key [] {
          open ${config.sops.secrets."apiverve/api-key".path}        
        }
      '';
    }

    {
      includes = ["location"];
      source = ./astro.nu;
    }
  ];

  sops.secrets."apiverve/api-key" = {};
}
