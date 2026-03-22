{pkgs, ...}: {
  imports = [../nushell];
  programs.zk.enable = true;

  nushell.extraScripts = [
    (pkgs.writeText "zk.nu" ''
      use ${../nb/get-nb-dir.nu} get-nb-dir

      def --wrapped _zk [...args: string] {
        SHELL=$"(^which bash)" ^zk ...$args
      }

      def --wrapped zk [...args: string] {
        mut is_main_zk = false

        let args = if not (".zk" | path exists) {
          $is_main_zk = true

          $args
          | append [--working-dir (get-nb-dir)]
        } else {
          $args
        }

        try {
          let subcommand = ($args | first)

          let result = if $subcommand == graph {
            _zk ...$args
            | complete
            | get stdout
          } else {
            _zk ...$args
          }

          if $is_main_zk and ($args | first) in [edit new] and (
            git -C (get-nb-dir) status --short | is-not-empty
          ) {
              nb sync
          } else if $subcommand == graph {
            $result
          }
        }
      }
    '')
  ];
}
