# View, edit, and upload files to/from remote storage
def files [] {
  help files
}

def print-error [text: string] {
  error make --unspanned {msg: $"(ansi red_bold)error(ansi reset): ($text)"}
}

def validate-remote [remote?: string] {
  if ($remote | is-empty) or (
    $remote in (files list remotes | lines)
  ) {
    return
  }

  print-error $"remote \"($remote)\" does not exist"
}

def select-remote [] {
  files list remotes
  | fzf
}

def get-remote [remote?: string] {
  let remote = if ($remote | is-empty) {
    select-remote
  } else {
    if ":" in $remote {
      $remote
      | split row :
      | first
    } else {
      $remote
    }
  }

  validate-remote $remote

  $remote
}

def get-path [interactive: bool remote?: string path?: string] {
  if $interactive {
    let selected_path = (
      rclone lsf $"($remote):($path)"
      | fzf
    )

    $path
    | path join $selected_path
  } else {
    if ($remote | is-not-empty) and ":" in $remote {
      let parts = ($remote | split row :)

      $parts
      | drop nth 0
      | str join :
    } else {
      $path
    }
  }
}

def get-remote-path [interactive: bool remote?: string path?: string] {
  let parsed_remote = (get-remote $remote)

  let remote = if $interactive {
    $parsed_remote
  } else {
    $remote
  }

  $"($parsed_remote):(get-path $interactive $remote $path)"
}

def get-files-directory [] {
  $env.HOME
  | path join files/
}

def get-local-path [remote: string path: string] {
  let path = if $remote in $path {
    $path
  } else {
    $"($remote)/($path)"
  }

  get-files-directory
  | path join $path
}

# Download files from remote
def "files download" [
  remote?: string # The name of the remote service
  path?: string # A path relative to <remote>:
  --force (-f) # Re-download file even if it already exists locally
  --interactive (-i) # Interactively select the file or directory to download
  --linked # (Dropbox only) Download the file using the `maestral` service
] {
  let parsed_remote = (get-remote $remote)
  let path = (get-path $interactive $remote $path)

  if $linked and $parsed_remote == dropbox {

    maestral excluded remove $path
  } else {
    let remote_path = (get-remote-path $interactive $parsed_remote $path)
    let local_path = (get-local-path $parsed_remote $path)

    if not $force and ($local_path | path exists) {
      print --stderr $"($local_path) already exists. Use `--force` to download again."

      return
    }

    let parent = (
      if (
        $local_path
        | rg '\.[a-zA-Z]+$'
        | complete
      ).exit_code == 0 {
        $local_path
        | path dirname
      } else {
        $local_path
      }
    )

    let result = (rclone sync $remote_path $parent | complete) 

    if $result.exit_code == 0 {
      print $"Downloaded ($local_path)"
    } else {
      print-error $"could not find remote file \"($remote_path)\""
    }
  }
}

# Download a file, open it in $EDITOR, and upload it after
def "files edit" [
  remote?: string # The name of the remote service
  path?: string # A path relative to <remote>:
] {
  let remote = (get-remote $remote)
  let path = (get-path false $path)

  files download $remote $path
  ^$env.EDITOR (get-local-path $remote $path)
  files upload $remote $path
}

# TODO
# def "files find" [
#   pattern: string
# ] {
#   files list dropbox
#   | lines
#   | where {$in | str contains --ignore-case $pattern}
#   | to text --no-newline
# }

# List files on remote
def "files list" [
  remote?: string # The name of the remote service
  path?: string # A path relative to <remote>:
  --interactive (-i) # Interactively select the subdirectory whose contents to list
] {
  let path = (get-remote-path $interactive $remote $path)

  rclone lsf $path
  | lines
  | to text --no-newline
}

alias "files ls" = files list

# List locally downloaded files
def "files list local" [
  remote?: string # The name of the remote service
  search?: string # Search pattern
] {
  let files_directory = (get-files-directory)
  mut search_path = $files_directory

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

  if ($files_directory | path exists) {
    fd --type file $search $search_path
  }
}

alias "files ls local" = files list local

# List available remotes
def "files list remotes" [] {
  rclone listremotes err> /dev/null
  | lines
  | str replace --regex ":$" ""
  | to text
}

alias "files ls remotes" = files list remotes

def confirm-remove [type?: string] {
  let type = if ($type | is-empty) {
    " "
  } else {
    $" ($type) "
  }

  let prompt = $"Are you sure you want to clear all downloaded($type)files? "

  (input $prompt | str downcase) in [y yes]
}

# Remove local files
def "files remove" [
  remote?: string # The name of the remote service
  path?: string # A path relative to <remote>:
  --force (-f) # Remove without confirmation
  --interactive (-i) # Interactively select the subdirectory whose contents to list
] {
  validate-remote $remote

  if not $force and not $interactive and ($path | is-empty) and not (
    confirm-remove $remote
  ) {
    return
  }

  let remote = if $interactive and ($remote | is-empty) {
    select-remote
  } else {
    $remote
  }

  let files_directory = (get-files-directory)

  let paths = if $interactive {
    fd --type file "" ($files_directory | path join $remote)
    | fzf --multi
    | lines
  } else {
    let parsed_path = if ($remote | is-empty) {
      $files_directory
    } else if ($path | is-empty) {
      $files_directory
      | path join $remote
    } else {
      [$files_directory $remote $path]
      | path join
    }

    let path = if ($path | is-not-empty) and not ($parsed_path | path exists) {
      print --stderr $"(
        ansi yellow_bold
      )warning(ansi reset)(ansi default_bold):(
        ansi reset
      ) no files or directories matching \"($path)\" found in remote \"($remote)\""

      let potential_files = try {
        fd --type file ($parsed_path | path basename) ($parsed_path | path dirname) err> /dev/null
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

  for path in $paths {
    rm --force --recursive $path
  }
}

# Setup remotes
def "files setup" [] {
  rclone config
}

# Upload a file to remote
def "files upload" [
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
    let files_directory = (get-files-directory)

    let remote = if ($local_path | str starts-with $files_directory) {
      $local_path
      | split row $files_directory
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
    $local_path
    | str replace $"(get-files-directory)($remote)/" ""
  }

  # TODO: handle remote path being dir vs file
  rclone copy $local_path (get-remote-path $remote $remote_path)
}
