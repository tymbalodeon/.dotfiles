{
  pkgs,
  src,
  ...
}: {
  home.packages = [
    src.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs.nushell = let
    srcHook = "~/.src-cd.nu";
  in {
    extraConfig = "source ${srcHook}";

    extraEnv = let
      srcPackage = src.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in "${srcPackage}/bin/src hook | save --force ${srcHook}";
  };
}
