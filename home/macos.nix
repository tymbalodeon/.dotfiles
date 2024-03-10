{ ... }:

rec {
  imports = [ ./home.nix ];

  home = {
    file = { ".hushlogin".source = ../.hushlogin; };
    homeDirectory = "/Users/benrosen";
  };

  programs.kitty.settings = {
    hide_window_decorations = "yes";
    macos_quit_when_last_window_closed = "yes";
    shell = "${home.homeDirectory}/.nix-profile/bin/nu";
  };
}
