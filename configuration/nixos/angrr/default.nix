{
  programs.direnv.angrr = {
    autoUse = true;
    enable = true;
  };

  services.angrr = {
    enable = true;
    # period = "7d";
  };
}
