{pkgs, ...}: {
  home = {
    file = {
      ".nb/.plugins/csv.nb-plugin".source = ./csv.nb-plugin;
      ".nb/.plugins/tags.nb-plugin".source = ./tags.nb-plugin;
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
  ];
}
