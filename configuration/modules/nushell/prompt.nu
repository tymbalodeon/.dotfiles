def make-hex [color_code: string] {
  $"#($color_code)"  
}

def create_left_prompt [
  dark_foreground_color: string
  highlight_color: string
] {
  let home =  $nu.home-path

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

    let dark_foreground_color = (make-hex $dark_foreground_color)
    let branch_color = (make-hex $highlight_color)
    let change_id_color = (make-hex $highlight_color)

    $"($prompt) (
      ansi $branch_color
    )($branch) (ansi $change_id_color)(
      $change_id
    )(ansi reset)\n"
  } catch {
    $prompt + $"\n" 
  }
}
