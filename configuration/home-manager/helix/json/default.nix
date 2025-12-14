{pkgs, ...}: {
  programs.helix = {
    extraPackages = with pkgs; [
      prettierd
      vscode-langservers-extracted
    ];

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
