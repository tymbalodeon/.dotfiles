# View, edit, and upload files to/from remote storage
def files [] {
  help files
}

def print-error [text: string] {
  error make --unspanned {msg: $"(ansi red_bold)error(ansi reset): ($text)"}
}

def get-remote [remote?: string] {
  let valid_remotes = (files list-remotes)

  if ($remote | is-empty) {
    $valid_remotes
    | fzf
  } else {
    if ($remote in $valid_remotes) {
      $remote
    } else {
      print-error $"remote \"($remote)\" does not exist"
    }
  }
}

def get-path [interactive: bool remote: string path?: string] {
  if $interactive {
    rclone lsf $"($remote):($path)"
    | fzf
  } else {
    $path
  }
}

def get-remote-path [interactive: bool remote?: string path?: string] {
  let remote = (get-remote $remote)
  let path = (get-path $interactive $remote $path)

  $"($remote):($path)"
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
  --linked # (Dropbox only) Download the file using the `maestral` service
] {
  let remote = (get-remote $remote)
  let path = (get-path $remote $path)

  if $linked and $remote == dropbox {

    maestral excluded remove $path
  } else {
    let remote_path = (get-remote-path $remote $path)
    let local_path = (get-local-path $remote $path)

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

    rclone sync $remote_path $parent
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

# List files on remote
def "files list" [
  remote?: string # The name of the remote service
  path?: string # A path relative to <remote>:
  --interactive (-i) # Interactively select the subdirectory whose contents to list
] {
  let path = (get-remote-path $interactive $remote $path)

  rclone lsf $path
  | lines
  | each {prepend $path | str join}
  | to text --no-newline
}

alias "files ls" = files list

# List available remotes
def "files list-remotes" [] {
  rclone listremotes err> /dev/null
  | lines
  | str replace --regex ":$" ""
  | to text
}

alias "files ls-remotes" = files list-remotes

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
