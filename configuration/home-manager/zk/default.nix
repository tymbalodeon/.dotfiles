{pkgs, ...}: {
  imports = [../nushell];
  programs.zk.enable = true;

  nushell.extraScripts = [
    (pkgs.writeText "zk.nu" ''
      use ${../nb/get-nb-dir.nu} get-nb-dir

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
          SHELL=$"(^which bash)" ^zk ...$args

          if $is_main_zk and ($args | first) in [edit new] {
            if (git -C (get-nb-dir) status --short | is-not-empty) {
              nb sync
            }
          }
        }

      }
    '')
  ];
}
