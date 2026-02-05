# Interactively search for a directory and cd into it
def --env f [
  directory?: # Limit the search to this directory
] {
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

  let path = (
    $directory
    | path join (
        fd --hidden "" $directory
        | str replace --all $"($directory)/" ""
        | lines
        | sort
        | to text
        | fzf --exact --scheme path
      )
  )

  if ($path | path type) == dir {
    cd $path
  } else {
    bash -c $"xdg-open '($path)' &"
  }
}
