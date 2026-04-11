{
  imports = [
    ../fzf
    ../nushell
  ];

  nushell.extraScripts = [
    {
      includes = ["start-process"];
      name = "storage";

      text =
        #nushell
        ''
          # View, edit, and upload files to/from remote storage
          def storage [] {
            help storage
          }

          alias st = storage

          def print-error [text: string] {
            error make --unspanned {msg: $text}
          }

          def get-remote [remote?: string] {
            let remote = if ($remote | is-empty) {
              return "dropbox"
            } else {
              $remote
              | split row :
              | first
            }

            if ($remote not-in (storage list remotes | lines)) {
              print-error $"remote \"($remote)\" does not exist"
            }

            $remote
          }

          def get-storage-directory [remote?: string] {
            $env.HOME
            | path join storage $remote
          }

          # Browse local files
          def "storage browse local" [
            path?: string # A path relative to <remote>:
            --remote: string # The name of the remote service
          ] {
            let local_storage_path = (get-storage-directory (get-remote $remote))

            let path = if ($path | is-empty) {
              $local_storage_path
            } else {
              $local_storage_path
              | path join $path
            }

            if ($path | path exists) {
              yazi $path
            }
          }

          alias "storage br local" = storage browse local
          alias "storage br l" = storage browse local
          alias "storage browse l" = storage browse local
          alias "storage browse" = storage browse local
          alias "storage br" = storage browse local

          # Browse remotes
          def "storage browse remote" [
            --remote: string # The name of the remote service
            --web # Browse remote in the browser, using remote website
            --web-rclone # Browse remote in the browser, using rclone
          ] {
            let remote = (get-remote $remote)

            if $web_rclone {
              rclone rcd --rc-web-gui --rc-user=admin --rc-pass=pass --rc-addr=:5572
            } else if $web {
              let host = match $remote {
                "dropbox" => "dropbox.com"
                "google" => "drive.google.com"
              }

              start-process xdg-open $"https://($host)"
            } else {
              rclone ncdu $"($remote):"
            }
          }

          alias "storage br remote" = storage browse remote
          alias "storage br r" = storage browse remote
          alias "storage browse r" = storage browse remote

          const SELECT_ALL = "--- SELECT ALL ---"

          export def select-remote-path [
            remote: string
            path?: string
            --allow-directories
            --no-files
          ] {
            const TMP_FILE = "/tmp/storage"

            "false" | save --force $TMP_FILE

            mut remote_path = if ($path | is-empty) {
              ""
            } else {
              $path
            }

            mut recurse = true

            while $recurse {
              let files = (
                rclone lsjson $"($remote):($remote_path)"
                | from json
              )

              let options = if $no_files {
                $files
                | where {$in.IsDir}
              } else {
                $files
              }

              let options = (
                $options
                | each {|file| if $file.IsDir {$"($file.Path)/"} else {$file.Path}}
              )

              let options = if $allow_directories or $no_files {
                $options
                | append $SELECT_ALL
              } else {
                $options
              }

              if ($options | length) == 1 and ($options | first) == $SELECT_ALL {
                break
              }

              let preview_string = $"
                file={}

                if [[ ! {} =~ .*\"($SELECT_ALL)\".* ]]; then
                  remote_path="($remote_path)"
                  rclone lsf \"($remote):''${remote_path%/}/$file\"
                fi
              "

              let selection = (
                $options
                | to text
                | (
                    fzf
                      --bind $"ctrl-backspace:execute-silent\(echo true > ($TMP_FILE)\)+abort"
                      --multi
                      --preview $preview_string
                  )
                | complete
              )

              let exit_code = $selection.exit_code
              let selection = ($selection.stdout | str trim)

              if (open $TMP_FILE | into bool) {
                if ($remote_path | is-empty) {
                  return
                }

                $remote_path = ($remote_path | path split | drop | path join)

                continue
              } else {
                if ($exit_code == 130) {
                  return
                }
              }

              if ($selection | lines | length) > 1 {
                let remote_path = $remote_path

                return (
                  $selection
                  | lines
                  | each {|path| $remote_path | path join $path}
                  | to text --no-newline
                )
              }

              $remote_path = ($remote_path | path join $selection)

              if ($remote_path | str ends-with $SELECT_ALL) {
                break
              }

              $recurse = (
                $files
                | where Path == ($remote_path | path basename)
                | first
                | get IsDir
              ) or (
                ($remote_path | path split | last) == $SELECT_ALL
              )
            }

            $remote_path
            | str replace $SELECT_ALL ""
          }

          def get-local-path [remote: string path: string] {
            let path = if $remote in $path {
              $path
              | str replace $"($remote)/" ""
              | str replace $"($remote):" ""
            } else {
              $path
            }

            get-storage-directory $remote
            | path join $path
          }

          def print-warning [text: string] {
            print $"(ansi yellow_bold)warning(ansi reset): ($text)"
          }

          export def is-directory [remote: string remote_path: string] {
            let json = (
              rclone lsjson $"($remote):($remote_path)"
              | from json
            )

            not (($json | length) == 1 and not ($json | first | get IsDir))
          }

          # Download files from remote
          export def "storage download" [
            path?: string # A path relative to <remote>:
            --force (-f) # Re-download file even if it already exists locally
            --interactive (-i) # Interactively select the path to download
            --quiet # Suppress output
            --pipe # Output downloaded filenames for piping to other commands
            --remote: string # The name of the remote service
            --to: string # Download to this directory instead fo the standard one
          ] {
            let remote = (get-remote $remote)

            let remote_path = if $interactive or ($path | is-empty) {
              select-remote-path --allow-directories $remote $path
            } else {
              $path
            }

            if ($remote_path | is-empty) {
              return
            }

            let local_path = if ($to | is-empty) {
              get-local-path $remote $remote_path
            } else {
              $to
            }

            if not $force and ($to | is-empty) and ($local_path | path exists) {
              (
                print-warning
                  $"($local_path) already exists. Use `--force` to download again."
              )

              return
            }

            let is_directory = (is-directory $remote $remote_path)

            let parent = if ($to | is-empty) {
              if $is_directory {
                $local_path
              } else {
                $local_path
                | path dirname
              }
            } else {
              if ($local_path | path exists) {
                if $is_directory and ($local_path | path type) != dir {
                  $local_path
                  | path dirname
                } else {
                  $local_path
                }
              } else {
                if ($local_path | path parse | get extension | is-empty) {
                  $local_path
                } else {
                  $local_path
                  | path dirname
                }
              }
            }

            let result = (
              rclone sync --fix-case $"($remote):($remote_path)" $parent
              | complete
            )

            if $result.exit_code == 0 {
              let files = if $is_directory {
                rclone lsjson $"($remote):($remote_path)"
                | from json
                | get Path
                | each {
                    |path|

                    {
                      from: ($remote_path | path join $path)
                      to: ($parent | path join $path)
                    }
                  }
              } else {
                {
                  from: ($remote_path)
                  to: ($parent | path join ($remote_path | path basename))
                }
              }

              if $pipe {
                $files.to
              } else if not $quiet {
                for file in $files {
                  print $"Downloaded ($file.from) to ($file.to)"
                }
              }
            } else {
              print-error $"could not find remote file \"($remote_path)\""
            }
          }

          alias "storage down" = storage download

          # Download a file, open it in $EDITOR, and upload it after
          def "storage edit" [
            path?: string # A path relative to <remote>:
            --remote: string # The name of the remote service
          ] {
            let remote = (get-remote $remote)

            let remote_path = if ($path | is-empty) {
              select-remote-path $remote
            } else {
              $path
            }

            storage download --remote $remote $remote_path
            let local_path = (get-local-path $remote $remote_path)
            ^$env.EDITOR $local_path
            storage upload --remote $remote $local_path $remote_path
          }

          # Show remote info
          def "storage info" [
            --remote: string # The name of the remote service
          ] {
            rclone about $"(get-remote $remote):"
          }

          # List locally downloaded files
          def "storage list local" [
            path?: string # A path relative to <remote>:
            --absolute-path # Show the absolute path of the files
            --remote: string # The name of the remote service
          ] {
            let storage_directory = (get-storage-directory (get-remote $remote))

            let path = if ($path | is-empty) {
              $storage_directory
            } else {
              $storage_directory
              | path join $path
            }

            if ($path | path exists) {
              let files = (fd --type file "" $path)

              if ($files | is-empty) {
                return
              }

              if $absolute_path {
                $files
              } else {
                $files
                | str replace --all $"($path)/" ""
              }
            }
          }

          alias "storage list" = storage list local
          alias "storage ls local" = storage list local
          alias "storage ls l" = storage list local
          alias "storage ls" = storage list local

          def get-remote-path [remote?: string path?: string] {
            $"(get-remote $remote):($path)"
          }

          # List remote files
          export def "storage list remote" [
            path?: string # A path relative to <remote>:
            --interactive (-i) # Interactively select the subdirectory whose contents to list
            --remote: string # The name of the remote service
          ] {
            let remote = (get-remote $remote)

            let path = if $interactive {
              select-remote-path $remote --no-files
            } else {
              $path
            }

            let path = (get-remote-path $remote $path)

            rclone lsf $path
            | lines
            | to text --no-newline
          }

          alias "storage ls remote" = storage list remote
          alias "storage ls r" = storage list remote

          # List available remotes
          def "storage list remotes" [] {
            rclone listremotes err> /dev/null
            | lines
            | str replace --regex ":$" ""
            | to text
          }

          alias "storage ls remotes" = storage list remotes

          # Move (rename) remote and local files
          def "storage move" [
            from: string # The existing file to move/rename
            to: string # The new name/path to move to
            --force (-f) # Remove without confirmation
            --remote: string # The name of the remote service
          ] {
            let remote = (get-remote $remote)

            let confirmed = try {
              rclone lsjson $"($remote):($to)" out+err> /dev/null
              print-warning $"path \"($to)\" exists and would be overwritten"

              let prompt = $"Are you sure you want to overwrite \"(
                $to
              )\" with \"($from)\"? [y/N]: "

              (input $prompt) in [Yy]
            }  catch {
              true
            }

            if $confirmed {
              rclone moveto $"($remote):($from)" $"($remote):($to)"
            }
          }

          alias "storage mv" = storage move

          # Interactively select and open a file from local storage
          def "storage open" [
            path?: string # A path relative to <remote>:
            --remote: string # The name of the remote service
          ] {
            let storage_directory = (get-storage-directory (get-remote $remote))

            let path = if ($path | is-not-empty) {
              $storage_directory
              | path join $path
            } else {
              $storage_directory
            }

            let remove_prefix = if ($path | is-empty) {
              let local_remotes = (ls $storage_directory)

              if ($local_remotes | length) == 1 {
                $local_remotes.name
                | first
              }
            } else {
              $path
            }

            let remove_prefix = $"($remove_prefix)/"

            let file = (
              fd --type file "" $path
              | each {str replace --all $remove_prefix ""}
              | to text
              | fzf
            )

            start-process xdg-open ($file | prepend $remove_prefix | str join)
          }

          def confirm-remove [remote?: string] {
            let remote = if ($remote | is-empty) {
              " "
            } else {
              $" ($remote) "
            }

            let prompt = $"Are you sure you want to clear all downloaded($remote)files? "

            (input $prompt | str downcase) in [y yes]
          }

          # Remove files from local and remote
          def "storage remove" [
            path?: string # A path relative to <remote>:
            --force (-f) # Remove without confirmation
            --remote: string # The name of the remote service
          ] {
            let remote = (get-remote $remote)

            if $force {
              remove local --force --remote $remote $path
              remove remote --force --remote $remote $path
            } else {
              remove local --remote $remote $path
              remove remote --remote $remote $path
            }
          }

          alias "storage rm" = storage remove

          # Remove local files
          def "storage remove local" [
            path?: string # A path relative to <remote>:
            --force (-f) # Remove without confirmation
            --interactive (-i) # Interactively select the subdirectory whose contents to list
            --remote: string # The name of the remote service
          ] {
            let remote = (get-remote $remote)

            if not $force and not $interactive and ($path | is-empty) and not (
              confirm-remove $remote
            ) {
              return
            }

            let storage_directory = (get-storage-directory $remote)

            let paths = if $interactive {
              let files = (fd --type file "" ($storage_directory | path join $remote))

              if ($files | is-empty) {
                return
              }

              $files
              | fzf --multi
              | lines
            } else {
              let parsed_path = if ($path | is-not-empty) {
                $storage_directory
                | path join $path
              } else {
                $storage_directory
              }

              if ($path | is-not-empty) and not ($parsed_path | path exists) {
                print --stderr $"(
                  ansi yellow_bold
                )warning(ansi reset)(ansi default_bold):(
                  ansi reset
                ) no files or directories matching \"(
                  $path
                )\" found in remote \"($remote)\""

                let potential_files = try {
                  (
                    fd
                      --type file
                      ($parsed_path | path basename)
                      ($parsed_path | path dirname)
                      err> /dev/null
                  )
                  | lines
                } catch {
                  return
                }

                let paths = if ($potential_files | length) == 0 {
                  return
                } else if ($potential_files | length) == 1 {
                  $potential_files
                } else {
                  $potential_files
                  | to text
                  | fzf --multi
                }

                print --stderr "Did you mean one of the following?"
                print --stderr ($paths | each {$"  - ($in)"} | to text --no-newline)

                return
              } else {
                [$parsed_path]
              }
            }

            # TODO: confirm removal if not force

            for path in $paths {
              ^rm --force --recursive $path
            }
          }

          alias "storage rm local" = storage remove local
          alias "storage rm l" = storage remove local

          # Remove remote files
          def "storage remove remote" [
            path?: string # A path relative to <remote>:
            --force (-f) # Remove without confirmation
            --remote: string # The name of the remote service
          ] {
            let remote = (get-remote $remote)

            let path = if ($path | is-empty) {
              select-remote-path --allow-directories $remote
            } else {
              $path
            }

            let remote_path = $"($remote):($path)"

            let contents = try {
              rclone lsjson $remote_path err> /dev/null
              | from json
            } catch {
              print-warning $"($path) not found"

              return
            }

            let command = if ($contents | length) == 1 and not ($contents | first | get IsDir) {
              "delete"
            } else {
              "purge"
            }

            if $force or (
              input $"Are you sure you want to remove ($path)? [y/N]: "
              | str downcase
            ) in [y yes] {
              rclone $command $remote_path
            }
          }

          alias "storage rm remote" = storage remove remote
          alias "storage rm r" = storage remove remote

          # Setup remotes
          def "storage setup" [] {
            rclone config
          }

          # Upload a file to remote
          export def "storage upload" [
            local_path?: string # The local file to upload
            remote_path?: string # The remote path to upload to
            --remote: string # The name of the remote service
          ] {
            let remote = (get-remote $remote)

            let local_path = if ($local_path | is-empty) {
              fd "" (get-storage-directory $remote)
              | lines
              | to text
              | fzf
            } else {
              $local_path
            }

            if not ($local_path | path exists) {
              print-error $"\"($local_path)\" not found"
            }

            let local_path = (realpath ($local_path | path expand))

            let remote_path = if ($remote_path | is-not-empty) {
              $remote_path
            } else {
              let storage_directory = (get-storage-directory $remote)

              if $storage_directory in $local_path {
                $local_path
                | str replace $storage_directory ""
              } else {
                $local_path
                | path basename
              }
            }

            let remote_path = ((get-remote-path $remote $remote_path))

            let remote_path = if (
              $local_path
              | path type
            ) == file {
              let basename = ($local_path | path basename)

              if $basename in $remote_path or (
                $local_path
                | path parse
                | get extension
                | is-not-empty
              ) {
                $remote_path
              } else {
                $remote_path
                | path join $basename
              }
            } else {
              $remote_path
            }

            let command = if ($local_path | path type) == file {
              "copyto"
            } else {
              "copy"
            }

            rclone $command $local_path $remote_path
          }

          alias "storage up" = storage upload
        '';
    }
  ];

  programs.rclone.enable = true;
}
