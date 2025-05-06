{pkgs, ...}: {
  programs.helix = {
    extraPackages = with pkgs; [
      alejandra
      nixd
    ];

    languages.language = [
      {
        auto-format = true;
        formatter.command = "alejandra";
        name = "nix";
      }
    ];
  };
}
