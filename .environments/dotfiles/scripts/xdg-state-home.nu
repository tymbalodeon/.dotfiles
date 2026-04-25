export def main [] {
  try {
    $env.XDG_STATE_HOME
  } catch {
    $env.HOME
    | path join .local/state
  }
}

