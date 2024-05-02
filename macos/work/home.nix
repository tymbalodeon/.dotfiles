{pkgs, ...}: {
  home = {
    file.".gitconfig".source = ./.gitconfig;

    packages = with pkgs; [
      python3
      rufo
      solargraph
    ];
  };

  imports = [../home.nix];
}
