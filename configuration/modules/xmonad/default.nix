{
  home.file = {
    ".config/xmonad/xmonad.hs".source = ./xmonad.hs;
    ".xprofile".source = ./.xprofile;
  };

  # FIXME: get this to work/show up in the login screen
  # xsession = {
  #   enable = true;

  #   windowManager.xmonad = {
  #     config = ./xmonad.hs;
  #     enableContribAndExtras = true;
  #     enable = true;
  #   };
  # };
}
