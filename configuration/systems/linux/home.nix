{pkgs, ...}: {
  home = {
    file = {
      ".config/nushell/aliases.nu".source = ../../nushell/aliases.nu;
      ".config/nushell/cloud.nu".source = ../../nushell/cloud.nu;
      ".config/nushell/colors.nu".source = ../../nushell/colors.nu;
      ".config/nushell/f.nu".source = ../../nushell/f.nu;
      ".config/nushell/prompt.nu".source = ../../nushell/prompt.nu;
      ".config/nushell/src.nu".source = ../../nushell/src.nu;
      ".config/nushell/theme-function.nu".source = ../../systems/nixos/nushell/theme-function.nu;
      ".config/nushell/theme.nu".source = ../../nushell/theme.nu;
      ".config/nushell/themes.toml".source = ../../nushell/themes.toml;
      ".config/tealdeer/config.toml".source = ../../tealdeer/config.toml;
      ".config/tinty/fzf.toml".source = ./tinty/fzf.toml;
    };

    homeDirectory = "/home/benrosen";

    packages = with pkgs; [
      cantarell-fonts
    ];
  };

  imports = [../../home.nix];
  nixpkgs.config.allowUnfree = true;

  programs = {
    ghostty = {
      enable = true;
      installBatSyntax = true;

      settings = {
        font-family = "Fira Code";

        font-feature = [
          "+zero"
          "+onum"
          "+cv30"
          "+ss09"
          "+cv25"
          "+cv26"
          "+cv32"
          "+ss07"
        ];

        font-size = 8;

        keybind = [
          "ctrl+shift+h=new_split:left"
          "ctrl+shift+j=new_split:down"
          "ctrl+shift+k=new_split:up"
          "ctrl+shift+l=new_split:right"
          "ctrl+shift+enter=new_split:auto"
          "ctrl+alt+h=goto_split:left"
          "ctrl+alt+j=goto_split:bottom"
          "ctrl+alt+k=goto_split:top"
          "ctrl+alt+l=goto_split:right"
          "ctrl+alt+[=goto_split:previous"
          "ctrl+alt+]=goto_split:next"
          "ctrl+alt+n=scroll_page_down"
          "ctrl+alt+p=scroll_page_up"
          "ctrl+alt+o=toggle_split_zoom"
        ];

        resize-overlay = "never";

        window-decoration = false;
      };
    };

    kitty = {
      enable = true;

      settings = {
        font_size = "8.0";
        kitty_mod = "ctrl+shift";
      };
    };
  };
}
