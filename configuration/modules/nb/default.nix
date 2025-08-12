{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      nb
      pandoc
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
