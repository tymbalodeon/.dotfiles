{pkgs, ...}: {
  imports = [../nushell];
  programs.zk.enable = true;

  nushell.extraScripts = [
    (pkgs.writeText "zk.nu" ''
      use ${../nb/get-nb-dir.nu} get-nb-dir

      def --wrapped zk [...args: string] {
        let args = if not (".zk" | path exists) {
          $args
          | append [--working-dir (get-nb-dir)]
        }

        SHELL=$"(^which bash)" ^zk ...$args
      }
    '')
  ];
}
