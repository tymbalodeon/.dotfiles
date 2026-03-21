{pkgs, ...}: {
  # TODO: keep zk-specific items in the zk module?
  programs.helix = {
    extraPackages = with pkgs; [
      harper
      markdown-oxide
      marksman
      prettierd
      zk
    ];

    languages = {
      language = [
        {
          auto-format = true;

          formatter = {
            args = [".md"];
            command = "prettierd";
          };

          language-servers = [
            {name = "zk";}
            {name = "marksman";}
            {name = "markdown-oxide";}
            {name = "harper-ls";}
          ];

          name = "markdown";
          roots = [".zk"];

          soft-wrap = {
            enable = true;
            wrap-at-text-width = true;
          };
        }
      ];

      language-server = {
        harper-ls = {
          args = ["--stdio"];
          command = "${pkgs.harper}/bin/harper-ls";
        };

        zk = {
          args = ["lsp"];
          command = "${pkgs.zk}/bin/zk";
        };
      };
    };
  };
}
