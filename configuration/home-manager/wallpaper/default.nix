{
  lib,
  pkgs,
  ...
}: {
  home = {
    activation.wallpaper = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir --parents ~/wallpaper
    '';

    file."wallpaper/default-wallpaper.jpeg".source = ./default-wallpaper.jpeg;

    packages = with pkgs; [
      imagemagick
      swaybg
    ];
  };

  imports = [
    ../fzf
    ../nushell
    ../storage
    ../yazi
  ];

  nushell.extraScripts = [
    {
      includes = ["storage"];
      name = "wallpaper";

      text =
        ''
          def default-wallpaper [] {
            "${./default-wallpaper.jpeg}"
          }
        ''
        + "\n"
        + builtins.readFile ./wallpaper.nu;
    }
  ];

  services.wpaperd = {
    enable = true;

    settings.default = {
      duration = "15m";
      exec = ./signal-waybar.sh;
      mode = "fit";
      path = "~/wallpaper";
    };
  };
}
