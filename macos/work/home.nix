{pkgs, ...}: {
  home = {
    file.".gitconfig".source = ./.gitconfig;

    packages = with pkgs; [
      pdm
      python3
      rufo
      solargraph
    ];
  };

  imports = [../home.nix];
}
