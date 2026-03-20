def get-path [directory?: string] {
  let directory = if ($directory | is-empty) {
    $env.HOME
  } else {
    $directory
    | path expand
  }

  let type = if ($directory | is-empty) {
    "directory"
  } else {
    if ($directory | path type) == dir {
      "file"
    } else {
      "directory"
    }
  }

  $directory
  | path join (
      fd --hidden "" $directory
      | str replace --all $"($directory)/" ""
      | lines
      | sort
      | to text
      | fzf --exact --scheme path
    )
}

# Search for files interactively
export def --env main [
  directory?: string # Search this directory
] {
  let path = (get-path $directory)

  if ($path | path type) == dir {
    cd $path
  } else {
    xdg-open $path
  }
}

# Search for files interactively and `cd` to directories, or parents of files
export def --env cd [
  directory?: string # Search this directory
] {
  let path = (get-path $directory)

  if ($path | path type) == dir {
    cd $path
  } else {
    cd ($path | path dirname)
  }
}

# Search for files interactively and edit them with $EDITOR
export def edit [
  directory?: string # Search this directory
] {
  let path = (get-path $directory)

  ^$env.EDITOR $path

  try {
    $path
    | path relative-to (pwd)
  } catch {
    $path
  }
}

# Search for files interactively and open them
export def open [
  directory?: string # Search this directory
  --application (-a): string # The command to open the file with
] {
  let path = (get-path $directory)

  if ($application | is-not-empty) {
    run-external $application $path
  } else {
    xdg-open $path
  }
}
