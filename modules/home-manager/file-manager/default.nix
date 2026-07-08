{hostType, ...}: {
  imports =
    [
      ./yazi
    ]
    ++ (
      if hostType != "home-manager"
      then [./nautilus]
      else []
    );
}
