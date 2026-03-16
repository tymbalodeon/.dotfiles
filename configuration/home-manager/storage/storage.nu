# View, edit, and upload files to/from remote storage
def storage [] {
  help storage
}

alias st = storage

def print-error [text: string] {
  error make --unspanned {msg: $'"($text)" does not exist'}
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

def get-storage-directory [] {
  $env.HOME | path join storage/
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

    start-process xdg-open $"https://($host)"
  } else {
    rclone ncdu $"($remote):"
  }
}

# Browse local files
def "storage browse local" [
  remote?: string # The name of the remote service
] {
  let local_storage_path = (
    get-storage-directory
    | path join (get-remote $remote)
  )

  if ($local_storage_path | path exists) {
    yazi $local_storage_path
  }
}

const SELECT_ALL = "--- SELECT ALL ---"

def select-remote-path [
  remote: string
  --allow-directories
  --no-files
] {
  mut remote_path = ""
  mut is_dir = true

  while ($is_dir or (($remote_path | path split | last) == $SELECT_ALL)) {
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

    let preview_string = $"
      file={}

      if [[ ! {} =~ .*\"($SELECT_ALL)\".* ]]; then
        rclone lsf \"($remote):($remote_path)$file\"
      fi
    "

    $remote_path = (
      $remote_path
      | path join (
        $options
        | to text
        | fzf --with-shell $"(^which bash) -c" --preview $preview_string
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
  | str replace $SELECT_ALL ""
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

def print-warning [text: string] {
  print $"(ansi yellow_bold)warning(ansi reset): ($text)"
}

# Download files from remote
export def "storage download" [
  path?: string # A path relative to <remote>:
  --force (-f) # Re-download file even if it already exists locally
  --quiet # Suppress output
  --remote: string # The name of the remote service
  --to: string # Download to this directory instead fo the standard one
] {
  let remote = (get-remote $remote)

  let remote_path = if ($path | is-empty) {
    select-remote-path --allow-directories $remote
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
    # FIXME: don't join with basename if basename is a dir in remote
    # TODO: display loading message while it runs (useful for downloading entire directories)
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
  remote?: string # The name of the remote service
] {
  rclone about $"(get-remote $remote):"
}
 
def get-remote-path [remote?: string path?: string] {
  $"(get-remote $remote):($path)"
}

# List remote files
def "storage list" [
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

# TODO: add this to nushell globally and use in other scripts (like f.nu, etc...)
def start-process [...args: string] {
  job spawn { run-external nohup ...$args } out+err> /dev/null
}

# Interactively select and open a file from local storage
def "storage open" [
  path?: string # A path relative to <remote>:
  --remote: string # The name of the remote service
] {
  let remote = (get-remote $remote)
  let storage_directory = (get-storage-directory)

  let path = if ($path | is-not-empty) {
    $remote
    | path join $path
  } else {
    $storage_directory
    | path join $remote
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

# Remove local files
def "storage remove" [
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

  let remote = (get-remote $remote)
  let storage_directory = (get-storage-directory)

  let paths = if $interactive {
    let files = (fd --type file "" ($storage_directory | path join $remote))

    if ($files | is-empty) {
      return
    }

    $files
    | fzf --multi
    | lines
  } else {
    let parsed_path = if ($remote | is-empty) {
      $storage_directory
    } else if ($path | is-empty) {
      $storage_directory
      | path join $remote
    } else {
      [$storage_directory $remote $path]
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

  # TODO: confirm removal if not force

  for path in $paths {
    rm --force --recursive $path
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

  rclone $command $local_path (get-remote-path $remote $remote_path)
}
