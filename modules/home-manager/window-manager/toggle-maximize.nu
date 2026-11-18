def focused-window-id [] {
  niri msg --json focused-window
  | from json
  | get id
}

def window-ids [] {
  niri msg --json windows
  | from json
  | get id
}

def main [] {
  let focused_id = (focused-window-id)

  for id in (window-ids) {
    niri msg action focus-window --id $id
    niri msg action maximize-window-to-edges
    niri msg action focus-window --id $focused_id
  }
}
