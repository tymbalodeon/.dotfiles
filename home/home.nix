{ pkgs, ... }:

{
  fonts.fontconfig.enable = true;

  home = {
    file = {
      ".gitconfig".source = ../.gitconfig;
      ".config/helix/config.toml".source = ../helix/config.toml;
      ".config/helix/languages.toml".source = ../helix/languages.toml;
    };

    packages = with pkgs; [
      bat
      dejavu_fonts
      delta
      eza
      fd
      fh
      fira
      font-awesome
      fzf
      gh
      git
      gitui
      jq
      lilypond-unstable
      helix
      macchina
      marksman
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
      nil
      nixfmt
      nodePackages.pyright
      pipx
      ripgrep
      ruff-lsp
      rustup
      sd
      taplo
      tldr
      vivid
      vscode-langservers-extracted
      yazi
    ];

    stateVersion = "23.11";
    username = "benrosen";

    sessionVariables = { EDITOR = "hx"; };
  };

  programs = {
    direnv = {
      enable = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      userName = "Ben Rosen";
      userEmail = "benjamin.j.rosen@gmail.com";
    };

    helix = {
      enable = true;
      defaultEditor = true;
    };

    home-manager.enable = true;

    kitty = {
      enable = true;
      extraConfig = "map kitty_mod+enter launch --cwd=current --type=window";

      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = "no";
        font_family = "CaskaydiaCove Nerd Font";
      };

      theme = "Gruvbox Dark";
    };

    nushell = {
      enable = true;
      configFile.source = ../nushell/config.nu;
      envFile.source = ../nushell/env.nu;
    };
  };
}
