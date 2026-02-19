{
  config,
  lib,
  pkgs,
  tsundeoku,
  ...
}: {
  config = {
    home = {
      file.".config/tsundeoku/tsundeoku.toml" = let
        cfg = config.tsundeoku;

        ignoredPaths = valueOrNull cfg.ignoredPaths ''
          ignored_paths = [
            ${lib.concatStringsSep "," cfg.ignoredPaths}
          ]
        '';

        isEmpty = value: value.isNull || value == [];

        sharedDirectories = valueOrNull cfg.sharedDirectories ''
          shared_directories = [
            ${lib.concatStringsSep "," cfg.sharedDirectories}
          ]
        '';

        valueOrNull = option: value:
          if isEmpty option
          then null
          else value;
      in ''
        ignored_paths = [
          ${lib.concatStringsSep "," cfg.ignoredDirectories}
        ]

        shared_directories = [
          ${lib.concatStringsSep "," cfg.sharedDirectories}
        ]
      '';

      packages = [
        tsundeoku.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };

  options.tsundeoku = let
    inherit (lib) mkOption types;
  in
    with types; {
      ignoredPaths = mkOption {
        default = [];
        type = listOf str;
      };

      localDirectory = mkOption {
        default = null;
        type = str;
      };

      scheduleInterval = mkOption {
        default = null;
        type = str;
      };

      sharedDirectories = mkOption {
        default = [];
        type = listOf str;
      };
    };
}
