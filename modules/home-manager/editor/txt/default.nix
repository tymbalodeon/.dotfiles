{
  programs.helix.languages.language = [
    {
      file-types = ["txt"];
      name = "txt";
      scope = "text.txt";

      soft-wrap = {
        enable = true;
        wrap-at-text-width = true;
      };
    }
  ];
}
