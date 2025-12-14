{pkgs, ...}: {
  programs.helix = {
    extraPackages = with pkgs; [
      bash-language-server
      shfmt
    ];

    languages.language = [
      {
        auto-format = true;
        formatter = {command = "shfmt";};
        name = "bash";
      }
    ];
  };
}
