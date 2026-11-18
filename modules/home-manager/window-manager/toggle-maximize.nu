def focused-window [] {
  niri msg --json focused-window
  | from json
}

def focused-window-id [] {
  focused-window
  | get id
}

def window-ids [] {
  niri msg --json windows
  | from json
  | get id
}

def state-file [] {
  let base = try {
    $env.XDG_STATE_HOME
  } catch {
    $env.HOME
    | path join .local/state
  }

  $base
  | path join window-manager-maximized
}

def maximize [] {
  try {
    not (open (state-file) | into bool)
  } catch {
    true
  }
}

def main [] {
  let focused_id = (focused-window-id)

  let half_of_display_width = (
    (
      xrandr err> /dev/null
      | rg '\*'
      | split words
      | first
      | split row "x"
      | first
      | into int
    ) / 2
  )

  let maximize = (maximize)
  print $maximize

  for id in (window-ids) {
    niri msg action focus-window --id $id

    let is_maximized = (
      (focused-window).layout.window_size.0 > $half_of_display_width
    )

    if $maximize and not $is_maximized {
      niri msg action maximize-window-to-edges
    } else if not $maximize and $is_maximized {
      niri msg action set-window-width --id $id 50%
    }
  }

  niri msg action focus-window --id $focused_id

  $maximize
  | save --force (state-file)
}
