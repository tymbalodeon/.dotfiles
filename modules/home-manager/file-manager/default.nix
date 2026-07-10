{hostType, ...}: {
  imports =
    [
      ./broot
      ./yazi
    ]
    ++ (
      if hostType != "home-manager"
      then [./nautilus]
      else []
    );
}
