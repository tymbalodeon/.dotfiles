def create_left_prompt [] {
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
      jj log
        --no-graph
        --revisions "ancestors(@)"
        --template "bookmarks ++ '\n'"
        err> /dev/null
      | lines
      | collect
      | where {is-not-empty}
      | first
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

$env.EDITOR = "hx"

$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
}

$env.NU_LIB_DIRS = [($nu.default-config-dir | path join "scripts")]
$env.NU_PLUGIN_DIRS = [($nu.default-config-dir | path join "plugins")]
$env.PROMPT_COMMAND = {|| create_left_prompt}
$env.PROMPT_COMMAND_RIGHT = {|| null}
$env.PROMPT_INDICATOR_VI_INSERT = "> "
$env.PROMPT_INDICATOR_VI_NORMAL = ">> "
$env.PROMPT_MULTILINE_INDICATOR = "::: "
