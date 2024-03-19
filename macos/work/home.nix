{...}: {
  home.file.".gitconfig".source = ./.gitconfig;
  imports = [../home.nix];
}
