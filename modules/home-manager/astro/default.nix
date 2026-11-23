{
  imports = [../shell/nushell];

  nushell.extraScripts = [
    {
      includes = ["location"];
      source = ./astro.nu;
    }
  ];
}
