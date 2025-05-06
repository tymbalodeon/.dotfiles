{pkgs, ...}: {
  programs.helix = {
    # TODO: figure out where vscode-json-language-server comes from
    extraPackages = [pkgs.prettierd];

    languages.language = [
      {
        auto-format = true;

        formatter = {
          args = [".json"];
          command = "prettierd";
        };

        name = "json";
      }

      {
        auto-format = true;

        formatter = {
          args = [".jsonc"];
          command = "prettierd";
        };

        name = "jsonc";
      }
    ];
  };
}
