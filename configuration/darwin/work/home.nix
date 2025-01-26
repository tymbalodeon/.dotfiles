{pkgs, ...}: {
  home = {
    file.".gitconfig".source = ./.gitconfig;

    packages = with pkgs; [
      pdm
      rufo
      solargraph
    ];
  };

  imports = [../home.nix];
}
