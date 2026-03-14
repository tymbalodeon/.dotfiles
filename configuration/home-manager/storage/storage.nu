# View, edit, and upload files to/from remote storage
def storage [] {
  help storage
}

def print-warning [text: string] {
  print $"(ansi yellow_bold)warning(ansi reset): ($text)"
}

def validate-remote [remote?: string] {
  if ($remote | is-empty) or (
    $remote in (storage list remotes | lines)
  ) {
    return
  }

  print-warning $"remote \"($remote)\" does not exist"
}

def get-remote [remote?: string] {
  let remote = if ($remote | is-empty) {
    return "dropbox"
  } else {
    $remote
    | split row :
    | first
  }

  validate-remote $remote

  $remote
}

def get-storage-directory [--linked] {
  $env.HOME
  | path join storage/
}

def get-local-path [remote: string path: string] {
  let path = if $remote in $path {
    $path
  } else {
    $"($remote)/($path)"
  }

  get-storage-directory
  | path join $path
}

# Browse remotes
def "storage browse" [
  remote?: string # The name of the remote service
  --web # Browse remote in the browser instead of the terminal
] {
  let remote = (get-remote $remote)

  if $web {
    let host = match $remote {
      "dropbox" => "dropbox.com"
      "google" => "drive.google.com"
    }

    job spawn { start $"https://($host)" } out> /dev/null
  } else {
    rclone ncdu $"($remote):"
  }
}

# Browse local files
def "storage browse local" [
  remote?: string # The name of the remote service
] {
  let path = (get-storage-directory)
  let remote = (get-remote $remote)

  let path = if ($remote | is-empty) {
    $path
  } else {
    $path
    | path join $remote
  }

  if ($path | path exists) {
    yazi $path
  }
}

def select-file [
  remote: string
  --allow-directories
] {
  mut remote_path = ""
  mut is_dir = true
  const SELECT_ALL = "--- SELECT ALL ---"

  while ($is_dir or ($remote_path | str ends-with $SELECT_ALL)) {
    let files = (
      rclone lsjson $"($remote):($remote_path)"
      | from json
    )

    $remote_path = (
      $remote_path
      | path join (
        $files
        | each {|file| if $file.IsDir {$"($file.Path)/"} else {$file.Path}}
        | append (if $allow_directories { $SELECT_ALL } else { null })
        | to text
        | fzf
      )
    )

    if ($remote_path | str ends-with $SELECT_ALL) {
      break
    }

    $is_dir = (
      $files
      | where Path == ($remote_path | path basename)
      | first
      | get IsDir
    )
  }

  $remote_path
}

# Download files from remote
export def "storage download" [
  remote?: string # The name of the remote service
  path?: string # A path relative to <remote>:
  --force (-f) # Re-download file even if it already exists locally
  --interactive (-i) # Interactively select the file or directory to download
  --linked # (Dropbox only) Download the file using the `maestral` service
  --quiet # Suppress output
  --to: string # (Not compatible with `--linked`) Download to this directory instead fo the standard one
] {
  let remote = (get-remote $remote)

  let remote_path = if ($path | is-empty) {
    select-file --allow-directories $remote
  } else {
    $path
  }

  let local_path = if ($to | is-not-empty) {
    if ($to | path type) != dir {
      print-error "`--to` must be a directory"
    } else {
      $to
    }
  } else {
    (get-local-path $remote $remote_path)
  }

  if not $force and ($to | is-empty) and ($local_path | path exists) {
    (
      print-warning
        $"($local_path) already exists. Use `--force` to download again."
    )

    return
  }

  let parent = if ($to | is-not-empty) {
    $to
  } else {
    let data = (
      rclone lsjson $"($remote):($remote_path)"
      | from json
    )

    if ($data | length) == 1 and not ($data | first | get IsDir) {
      $local_path
      | path dirname
    } else {
      $local_path
    }
  }

  let result = (rclone sync $"($remote):($remote_path)" $parent | complete)

  if $result.exit_code == 0 {
    if not $quiet {
      print $"Downloaded ($remote_path) to (
        $parent
        | path join ($remote_path | path basename)
      )"
    }
  } else {
    print-error $"could not find remote file \"($remote_path)\""
  }
}

# Download a file, open it in $EDITOR, and upload it after
def "storage edit" [
  remote?: string # The name of the remote service
  path?: string # A path relative to <remote>:
] {
  let remote = (get-remote $remote)

  let remote_path = if ($path | is-empty) {
    select-file $remote
  } else {
    $path
  }

  storage download $remote $remote_path
  let local_path = (get-local-path $remote $remote_path)
  ^$env.EDITOR $local_path
  storage upload $local_path $remote_path
}

# Show remote info
def "storage info" [
  remote?: string # The name of the remote service
] {
  let remote = (get-remote $remote)
  rclone about $"($remote):"
}

# List remote files
def "storage list" [
  remote?: string # The name of the remote service
  path?: string # A path relative to <remote>:
  --interactive (-i) # Interactively select the subdirectory whose contents to list
] {
  let remote = (get-remote $remote)
  let path = (get-remote-path $interactive $remote $path)

  rclone lsf $path
  | lines
  | to text --no-newline
}

alias "storage ls" = storage list

# List locally downloaded files
def "storage list local" [
  remote?: string # The name of the remote service
  search?: string # Search pattern
] {
  let storage_directory = (get-storage-directory)
  mut search_path = $storage_directory

  for item in [$remote $search] {
    if ($item | is-not-empty) {
      $search_path = (
        $search_path
        | path join $item
      )
    }
  }

  let search_path = if not ($search_path | path exists) {
    $search_path
    | path dirname
  } else {
    $search_path
  }

  let search = if ($search | is-empty) {
    ""
  } else {
    $search
  }

  if ($storage_directory | path exists) {
    fd --type file $search $search_path
  }
}

alias "storage ls local" = storage list local

# List available remotes
def "storage list remotes" [] {
  rclone listremotes err> /dev/null
  | lines
  | str replace --regex ":$" ""
  | to text
}

alias "storage ls remotes" = storage list remotes

def confirm-remove [type?: string] {
  let type = if ($type | is-empty) {
    " "
  } else {
    $" ($type) "
  }

  let prompt = $"Are you sure you want to clear all downloaded($type)files? "

  (input $prompt | str downcase) in [y yes]
}

def remove-linked-file [path: string] {
  maestral excluded add (
    $path
    | str replace $"(get-storage-directory --linked)/" ""
  )
}

# Remove local files
def "storage remove" [
  remote?: string # The name of the remote service
  path?: string # A path relative to <remote>:
  --force (-f) # Remove without confirmation
  --interactive (-i) # Interactively select the subdirectory whose contents to list
  --linked # (Dropbox only) Remove the file from the `maestral` managed folder
] {
  validate-remote $remote

  if not $force and not $interactive and ($path | is-empty) and not (
    confirm-remove $remote
  ) {
    return
  }

  let remote = (get-remote $remote)

  let storage_directory = if $linked {
    get-storage-directory --linked
  } else {
    get-storage-directory
  }

  let paths = if $interactive {
    fd --type file "" ($storage_directory | path join $remote)
    | fzf --multi
    | lines
  } else {
    let parsed_path = if ($remote | is-empty) {
      $storage_directory
    } else if ($path | is-empty) {
      if $linked {
        $storage_directory
      } else {
        $storage_directory
        | path join $remote
      }
    } else {
      let path_parts = if $linked {
        [$storage_directory $path]
      } else {
        [$storage_directory $remote $path]
      }

      $path_parts
      | path join
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

  if $linked {
    for path in $paths {
      if $path == (get-storage-directory --linked) {
        let paths = (fd --max-depth 1 --type dir "" $storage_directory | lines)

        for path in $paths {
          remove-linked-file $path
        }
      } else {
        remove-linked-file $path
      }
    }
  } else {
    for path in $paths {
      rm --force --recursive $path
    }
  }
}

alias "storage rm" = storage remove

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
  if not ($local_path | path exists) {
    print-error $"\"($local_path)\" not found"
  }

  let local_path = (realpath ($local_path | path expand))

  let remote = if ($remote | is-not-empty) {
    $remote
  } else {
    let storage_directory = (get-storage-directory)

    let remote = if ($local_path | str starts-with $storage_directory) {
      $local_path
      | split row $storage_directory
      | last
      | split row /
      | first
    } else {
      $remote
    }

    (get-remote $remote)
  }

  let remote_path = if ($remote_path | is-not-empty) {
    $remote_path
  } else {
    let storage_directory = (get-storage-directory)

    if $storage_directory in $local_path {
      $local_path
      | str replace $storage_directory ""
    } else {
      $local_path
      | path basename
    }
  }

  let command = if ($local_path | path type) == file {
    "copyto"
  } else {
    "copy"
  }

  rclone $command $local_path (get-remote-path false $remote $remote_path)
}
