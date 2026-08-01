{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;

    settings = {
      mgr = {
        show_hidden = true;
        sort_dir_first = false;
      };

      open.prepend_rules = [
        {
          url = "*/";
          use = ["open" "reveal"];
        }
      ];
    };

    shellWrapperName = "y";
  };
}
