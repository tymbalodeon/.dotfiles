{pkgs, ...}: {
  imports = [
    ../nushell
    ../sqlite
    ../storage
  ];

  nushell.extraScripts = [
    (pkgs.writeText "sync.nu" ''
      use ${../storage/storage.nu} "storage download"
      use ${../storage/storage.nu} "storage upload"

      const DUMP_FILE = ".task.dump.json"

      def database-file [] {
        $"($env.HOME)/.local/share/task/taskchampion.sqlite3"
      }

      def local-last-modified [] {
        open ~/.local/share/task/taskchampion.sqlite3
        | get operations
        | get data
        | each {from json}
        | where {($in | describe) != string and Update in ($in | columns)}
        | flatten
        | get timestamp
        | sort
        | reverse
        | first
      }

      def remote-last-modified [] {
        let dump_file = try {
          rclone lsjson $"dropbox:($DUMP_FILE)" out+err> /dev/null
        } catch {
          return
        }

        if ($dump_file | is-empty) {
          return
        }

        $dump_file
        | from json
        | first
        | get ModTime
      }

      def is-outdated [] {
        let remote_last_modified = (remote-last-modified)

        ($remote_last_modified | is-not-empty) and (
          $remote_last_modified
        ) > (local-last-modified)
      }

      def --wrapped task [...args: string] {
        if (is-outdated) {
          task load
        }

        ^task ...$args

        if ($args | each {$in in [
          add
          annotate
          append
          delete
          denotate
          done
          duplicate
          edit
          import
          import-v2
          log
          modify
          prepend
          purpe
          start
          stop
        ]} | any {into bool}) {
          task dump
        }
      }

      def "task dump" [] {
        let temporary_file = (mktemp --tmpdir XXX.json)

        open (database-file)
        | get tasks
        | get data
        | each {from json}
        | to json
        | save --force $temporary_file

        storage upload --remote dropbox $temporary_file $DUMP_FILE
        rm $temporary_file
      }

      def "task load" [] {
        let temporary_directory = (mktemp --directory)

        storage download --quiet --to $temporary_directory dropbox $DUMP_FILE
        ^task import ($temporary_directory | path join $DUMP_FILE)

        rm --force --recursive $temporary_directory
      }
    '')
  ];

  programs.taskwarrior = {
    colorTheme = "dark-16";
    enable = true;
    package = pkgs.taskwarrior3;
  };
}
