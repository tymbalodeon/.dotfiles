# TODO: hook me up to a keybinding!

def main [] {
  let focused_id = (
    niri msg focused-window
    | find --no-highlight "Window ID"
    | str replace "Window ID " ""
    | split row ":"
    | first
  )

  let ids = (
    niri msg windows
    | find --no-highlight "Window ID"
    | each {
      str replace "Window ID " ""
      | split row ":"
      | first
    }
  )

  for id in $ids {
    niri msg action focus-window --id $id
    niri msg action maximize-window-to-edges
    niri msg action focus-window --id $focused_id
  }
}
