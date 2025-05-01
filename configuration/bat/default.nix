{
  inputs,
  pkgs,
  ...
}: {
  home = {
    file = {
      ".config/bat/config".source = ./config;
      ".config/bat/syntaxes/nushell.sublime-syntax".source =
        inputs.nushell-syntax + "/nushell.sublime-syntax";
    };

    packages = with pkgs; [bat bat-extras.batman];
  };
}
