# TODO: change alt-space to be dmenu/rofi to match mac's spotlight
# TODO: find a replacement for the current alt-space (shift-alt-space?)
{
  home.file = {
    # TODO: put all of these in XDG_CONFIG_HOME?
    ".config/xmonad/xmonad.hs".source = ./xmonad.hs;
    ".xprofile".source = ./.xprofile;
    ".xmobarrc".source = ./.xmobarrc;
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
