{
  imports = [
    ../fzf
    ../shell/nushell
  ];

  nushell.extraScripts = [
    {
      includes = ["start-process"];
      name = "storage";
      source = ./storage.nu;
    }
  ];

  programs.rclone.enable = true;
}
