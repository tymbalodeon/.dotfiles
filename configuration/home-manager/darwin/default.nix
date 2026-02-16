{channel, ...}: {
  imports =
    [
      ../kitty
    ]
    ++ (
      if channel == "unstable"
      then [../aerospace]
      else []
    );

  kitty.font_size = 11.0;
}
