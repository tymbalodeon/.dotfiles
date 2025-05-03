-- TODO: figure out where to automatically set the following, to remap capslock
-- to esc
-- xmodmap -e "keycode 66 = Escape"
-- xmodmap -e "keycode 9  = Caps_Lock"
-- xmodmap -e "clear Lock"

import XMonad
import XMonad.Util.EZConfig

main :: IO ()
main = xmonad $ def 
  { terminal = "ghostty"
  }
