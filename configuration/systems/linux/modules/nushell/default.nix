{
  home.file = let nushell_module = ../../../../modules/nushell; in {
      ".config/nushell/aliases.nu".source = "${nushell_module}/aliases.nu";
      ".config/nushell/cloud.nu".source = "${nushell_module}/cloud.nu";
      ".config/nushell/colors.nu".source = "${nushell_module}/colors.nu";
      ".config/nushell/f.nu".source = "${nushell_module}/f.nu";
      ".config/nushell/prompt.nu".source = "${nushell_module}/prompt.nu";
      ".config/nushell/src.nu".source = "${nushell_module}/src.nu";
      ".config/nushell/theme-function.nu".source = ./theme-function.nu;
      ".config/nushell/theme.nu".source = "${nushell_module}/theme.nu";
      ".config/nushell/themes.toml".source = "${nushell_module}/themes.toml";
    };
}
