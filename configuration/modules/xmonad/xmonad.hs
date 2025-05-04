import XMonad
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Layout.Magnifier
import XMonad.Layout.ThreeColumns
import XMonad.Util.EZConfig

main :: IO ()
main = xmonad $ ewmhFullscreen $ ewmh $ xmobarProp def
  { terminal = "ghostty"
  }
