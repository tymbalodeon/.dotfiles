def create_left_prompt [] {
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
    # TODO: is it possible to pull color values from stylix to add color to the
    # branch/change id info?
    let branch = (
      (
        jj log
          --no-graph
          --revisions "ancestors(@)"
          --template "bookmarks ++ '\n'"
        | lines
        | where {is-not-empty}
        | first
      )
    )

    let change_id = (
      jj log --no-graph --revisions @ --template "change_id.shortest()"
    )

    (
      $"($prompt) \(($branch) - ($change_id)\)\n"
    )
  } catch {
    $prompt + $"\n" 
  }
}

$env.PROMPT_COMMAND = {|| create_left_prompt}
$env.PROMPT_COMMAND_RIGHT = {|| null}
$env.PROMPT_INDICATOR_VI_INSERT = "> "
$env.PROMPT_INDICATOR_VI_NORMAL = ">> "
$env.PROMPT_MULTILINE_INDICATOR = "::: "
