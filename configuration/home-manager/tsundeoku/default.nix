{
  pkgs,
  tsundeoku,
  ...
}: {
  home.packages = [
    tsundeoku.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
