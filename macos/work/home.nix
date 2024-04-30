{pkgs, ...}: {
  home = {
    file.".gitconfig".source = ./.gitconfig;

    packages = with pkgs; [
      nodePackages.bash-language-server
      python3
      rufo
      solargraph
      yamlfmt
      yaml-language-server
    ];
  };

  imports = [../home.nix];
}
