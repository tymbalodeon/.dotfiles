{pkgs, ...}: {
  programs.nushell = {
    configFile.source = ./config.nu;
    enable = true;
    envFile.source = ./env.nu;

    plugins = with pkgs.nushellPlugins; [
      formats
      gstat
      polars
      query
    ];
  };
}
