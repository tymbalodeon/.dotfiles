{pkgs, ...}: {
  home = {
    file = {
      ".nb/.plugins/tags.nb-plugin".source = ./tags.nb-plugin;
    };

    packages = with pkgs; [
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
