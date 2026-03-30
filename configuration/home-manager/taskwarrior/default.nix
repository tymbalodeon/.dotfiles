{pkgs, ...}: {
  imports = [
    ../fzf
    ../nushell
    ../sqlite
    ../storage
  ];

  nushell.extraScripts = [
    (pkgs.writeText "task.nu" ''
      use ${../storage/storage.nu} "storage download"
      use ${../storage/storage.nu} "storage upload"

      const DUMP_FILE = "task/task.dump.json"

      def database-file [] {
        let database_file = $"($env.HOME)/.local/share/task/taskchampion.sqlite3"

        if not ($database_file | path exists) {
          ^task out+err> /dev/null
        }

        $database_file
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

      def temporary-json-file [] {
        mktemp --tmpdir XXX.json
      }

      def tasks-file [tasks: table --pending] {
        let temporary_file = (temporary-json-file)

        $tasks
        | where {
            |task|

            if $pending {
              $task.status == pending
            } else {
              $task.status != pending
            }
          }
        | save --force $temporary_file

        $temporary_file
      }

      def archive-file [] {
        "task/archive.json"
      }

      # Save non-pending tasks to an archive file
      def "task archive" [] {
        let tasks = (
          open (database-file)
          | get tasks.data
          | each {from json}
        )

        let completed_tasks_file = (tasks-file $tasks)
        let existing_archived_tasks_file = (temporary-json-file)
        let merged_archived_tasks_file = (temporary-json-file)
        let pending_tasks_file = (tasks-file $tasks --pending)

        if (open $completed_tasks_file | is-not-empty) {
          let archive_file = (archive-file)

          let archive = try {
            (
              storage download
                --force $archive_file
                --to $existing_archived_tasks_file
            )

            open $existing_archived_tasks_file
          }

          $archive
          | append (open $completed_tasks_file)
          | save --force $merged_archived_tasks_file

          storage upload $merged_archived_tasks_file $archive_file
        }

        task load $pending_tasks_file

        rm $completed_tasks_file
        rm $existing_archived_tasks_file
        rm $merged_archived_tasks_file
        rm $pending_tasks_file
      }

      # Remove all tasks from the database
      def "task clear" [] {
        mv (database-file) (mktemp --tmpdir task-backup-XXX.sqlite3)
      }

      def get-dump-file [file?: string] {
        if ($file | is-empty) {
          $DUMP_FILE
        } else {
          $file
        }
      }

      # Save the current state of the database to a json file
      def "task dump" [file?: string] {
        task archive

        let temporary_file = (temporary-json-file)

        open (database-file)
        | get tasks.data
        | each {from json}
        | save --force $temporary_file

        (
          storage upload
            $temporary_file
            (get-dump-file $file)
            out+err> /dev/null
        )

        rm $temporary_file
      }

      # Load the remote tasks into the local database
      def "task load" [
        file?: string
        --interactive (-i)
      ] {
        task clear

        let temporary_directory = (mktemp --directory)

        let dump_file = if ($file | is-not-empty) {
          $file
        } else {
          let file = if $interactive {
            storage ls remote task
            | fzf
          } else {
            (get-dump-file $file)
          }

          storage download --quiet --to $temporary_directory $file

          $temporary_directory
          | path join ($file | path basename)
        }

        ^task import $dump_file
        rm --force --recursive $temporary_directory
      }

      # List projects
      def "task projects" [
        --all # Include projects from archived task
        --pending # Only include pending tasks
      ] {
        let current_projects = (
          open (database-file)
          | get tasks.data
          | each {from json}
        )

        let tasks = if $all {
          let archive_filename = (archive-file)

          let archive_file = (
            "/tmp"
            | path join ($archive_filename | path basename)
          )

          (
            storage download
              (archive-file)
              --quiet
              --to ($archive_file | path dirname)
          )

          let archived_projects = (open $archive_file)

          rm $archive_file

          $archived_projects
          | append $current_projects
        } else if $pending {
          $current_projects
          | where status == pending
        } else {
          $current_projects
        }

        $tasks
        | get --optional project
        | where {is-not-empty}
        | uniq
        | sort
        | to text --no-newline
      }
    '')
  ];

  programs.taskwarrior = {
    colorTheme = "dark-16";
    enable = true;
    package = pkgs.taskwarrior3;
  };
}
