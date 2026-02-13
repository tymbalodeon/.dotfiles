def create_left_prompt [] {
  # TODO: use `home-path` on 25.05
  let home =  $nu.home-dir

  let dir = (
    if (
     $env.PWD
     | path split
     | zip ($home | path split)
     | all { $in.0 == $in.1 }
    ) {
      ($env.PWD | str replace $home "~")
    } else {
      $env.PWD
    }
  )

  let prompt = (
    $"($dir)"
    | str replace --all
      (char path_sep)
      $"(char path_sep)"
  )

  try {
    let branch = (
      (
        jj log
          --no-graph
          --revisions "ancestors(@)"
          --template "bookmarks ++ '\n'"
          err> /dev/null
        | lines
        | where {is-not-empty}
        | first
      )
    )

    let change_id = (
      jj log
        --no-graph
        --revisions @
        --template "change_id.shortest()"
        err> /dev/null
    )

    $"($prompt) (ansi magenta)($branch) ($change_id)(ansi reset)\n"
  } catch {
    $prompt + $"\n" 
  }
}
