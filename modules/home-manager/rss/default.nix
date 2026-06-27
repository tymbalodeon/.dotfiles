{
  config,
  lib,
  pkgs,
  ...
}: let
  newsboatUrlsPath = "newsboat/urls";
in {
  browser.extraExtensionIDs = ["kfghpdldaipanmkhfpdcjglncmilendn"];

  home.activation.rss = let
    script =
      pkgs.writeScript "activate-rss"
      # nushell
      ''
        let config_path = (
          "${config.xdg.configHome}"
          | path join ${newsboatUrlsPath}
        )

        let remote_config = (open ${config.sops.secrets.${newsboatUrlsPath}.path})

        let config = if ($config_path | path type) != file {
          rm --force --recursive $config_path

          $remote_config
        } else {
          let local_config = (open $config_path)

          if ($local_config == $remote_config) {
            return
          }

          let local_parts = ($local_config | split row "\n\n")
          let remote_parts = ($remote_config | split row "\n\n")

          $remote_parts
          | first
          | lines
          | append ($local_parts | first | lines)
          | uniq
          | sort
          | append ""
          | append (
            $remote_parts
            | last
            | lines
            | append ($local_parts | last | lines)
            | uniq
            | sort
          )
          | to text --no-newline
        }

        $config
        | save --force $config_path
      '';
  in
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${lib.getExe pkgs.nushell} "${script}"
    '';

  imports = [
    ../browser
    ../secrets
    ../shell/nushell
  ];

  nushell.extraScripts = [{source = ./rss.nu;}];

  programs.newsboat = {
    autoFetchArticles.enable = true;
    autoReload = true;
    autoVacuum.enable = true;
    enable = true;

    extraConfig = ''
      bind j everywhere down
      bind k everywhere up

      color article            default default
      color background         default default
      color end-of-text-marker color8  default
      color hint-description   default color8
      color hint-separator     default color8
      color info               color4  color8
      color listfocus          default color8 bold
      color listfocus_unread   color2 color8 bold
      color listnormal         default default
      color listnormal_unread  color2  default
      color title              color14 color8

      feed-sort-order lastupdated

      highlight article "^(Feed|Title|Author|Link|Date): .+" color4 default bold
      highlight article "^(Feed|Title|Author|Link|Date):" color14 default bold
      highlight article "\\((link|image|video)\\)" color8 default
      highlight article "https?://[^ ]+" color4 default
      highlight article "\[[0-9]+\]" color6 default bold
    '';
  };

  sops.secrets.${newsboatUrlsPath} = {};
}
