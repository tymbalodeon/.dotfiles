{pkgs, ...}: {
  programs.helix = {
    extraPackages = [pkgs.alejandra];

    languages.language = [
      {
        auto-format = true;

        formatter = {
          args = ["-"];
          command = "yamlfmt";
        };

        name = "yaml";
      }
    ];
  };
}
