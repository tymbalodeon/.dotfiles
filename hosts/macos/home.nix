{ config, pkgs, specialArgs, ... }:

let
  FONTCONFIG_FILE =
    pkgs.makeFontsConf { fontDirectories = [ pkgs.freefont_ttf ]; };
in {
  home = {
    stateVersion = "23.11";

    username = "rrosen";
    homeDirectory = pkgs.lib.mkForce "/Users/benrosen";

    packages = with pkgs; [
      bat
      bottom
      dejavu_fonts
      delta
      dust
      emacs
      eza
      fd
      fh
      fzf
      gh
      git
      gitleaks
      gitui
      helix
      lilypond-unstable
      macchina
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
      nixfmt
      ripgrep
      sd
      tldr
      yazi
      zoxide
    ];

    file = {
      ".config/helix/config.toml".source = ../../helix/config.toml;
      ".config/helix/languages.toml".source = ../../helix/languages.toml;
      ".gitconfig".source = ../../.gitconfig;
    };

    sessionVariables = { FONTCONFIG_FILE = "${FONTCONFIG_FILE}"; };
  };

  programs = {
    direnv = {
      enable = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };

    helix = {
      enable = true;
      defaultEditor = true;
    };

    home-manager.enable = true;

    nushell = {
      enable = true;
      configFile.source = ../../nushell/config.nu;
      envFile.source = ../../nushell/env.nu;
      environmentVariables = { FONTCONFIG_FILE = "${FONTCONFIG_FILE}"; };
    };
  };
}
