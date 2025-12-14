{pkgs, ...}: {
  programs.helix = {
    extraPackages = with pkgs; [
      harper
      markdown-oxide
      marksman
      prettierd
    ];

    languages = {
      language = [
        {
          auto-format = true;

          formatter = {
            args = [".md"];
            command = "prettierd";
          };

          name = "markdown";

          soft-wrap = {
            enable = true;
            wrap-at-text-width = true;
          };
        }
      ];

      language-server.harper-ls = {
        args = ["--stdio"];
        command = "${pkgs.harper}/bin/harper-ls";
      };
    };
  };
}
