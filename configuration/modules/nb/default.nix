{
  config,
  pkgs,
  ...
}: {
  home = {
    file = let
      nu_default_config_dir = config.programs.nushell.configDirectory;
    in {
      ".nb/.plugins/csv.nb-plugin".source = ./csv.nb-plugin;
      ".nb/.plugins/tags.nb-plugin".source = ./tags.nb-plugin;
      "${nu_default_config_dir}/nb-cd.nu".source = ./nb-cd.nu;
    };

    packages = with pkgs; [
      csvlens
      nb
      pandoc
      readability-cli
      ripgrep
      socat
      tig
      w3m
    ];
  };

  imports = [
    ../bash
    ../bat
    ../git
    ../helix
    ../helix/markdown
    ../nushell
  ];
}
