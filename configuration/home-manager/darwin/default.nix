{
  channel,
  lib,
  pkgs,
  ...
}:
{
  home.activation.defaultBrowser = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${lib.getExe pkgs.defaultbrowser} browser
  '';

  imports =
    [
      ../brave
      ../kitty
    ]
    ++ (
      if channel == "unstable"
      then [../aerospace]
      else []
    );

  kitty.font_size = 11.0;
}
// lib.optionalAttrs (channel == "unstable") {
  targets.darwin.copyApps.enable = true;
  targets.darwin.linkApps.enable = false;
}
