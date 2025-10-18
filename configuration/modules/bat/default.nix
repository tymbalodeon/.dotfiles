{pkgs, ...}: {
  programs.bat = {
    config.style = "plain";
    enable = true;
    extraPackages = [pkgs.bat-extras.batman];

    syntaxes = {
      nushell = {
        file = "nushell.sublime-syntax";

        src = pkgs.fetchFromGitHub {
          hash = "sha256-paayZP6P+tzGnla7k+HrF+dcTKUyU806MTtUeurhvdg=";
          owner = "stevenxxiu";
          repo = "sublime_text_nushell";
          rev = "66b00ff639dc8cecb688a0e1d81d13613b772f66";
        };
      };
    };
  };
}
