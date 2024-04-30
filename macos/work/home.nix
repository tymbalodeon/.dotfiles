{pkgs, ...}: {
  home = {
    file.".gitconfig".source = ./.gitconfig;

    packages = with pkgs; [python3 yaml-language-server yamlfmt];
  };

  imports = [../home.nix];
}
