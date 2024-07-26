def src [
  url?: string # URL of the repo to clone
  --list # List cloned repos
  --user: string # List cloned repos for user
] {
  let src_directory = ($env.HOME | path join "src")

  if $list {
    if ($user | is-empty) {
      return (tree $src_directory --level 3)    
    } else {
      return (tree $"($src_directory)/github.com/($user)" --level 1)
    }
  }

  let values = if (
    $url
    | str starts-with "git@"
  ) {
    $url 
    | split row "@" 
    | split row ":"
    | split row "/"
    | drop nth 0
  } else if (
    $url
    | str starts-with "http"
  ) {
    $url 
    | split row "://" 
    | split row "/"
    | drop nth 0
  }

  let target = (
    $src_directory
    | path join (
      $values | first
    ) | path join (
      $values | get 1
    ) | path join (
      $values | last | str replace ".git" ""    
    )
  ) 

  if not ($target | path exists) {
    git clone $url $target
  }
}
