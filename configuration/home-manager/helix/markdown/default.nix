{pkgs, ...}: {
  # TODO: keep zk-specific items in the zk module?
  programs.helix = {
    extraPackages = with pkgs; [
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
          ];

          name = "markdown";
          roots = [".zk"];

          soft-wrap = {
            enable = true;
            wrap-at-text-width = true;
          };
        }
      ];

      language-server.zk = {
        args = ["lsp"];
        command = "${pkgs.zk}/bin/zk";
      };
    };
  };
}
