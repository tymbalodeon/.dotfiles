def screenshot-path [] {
  let current_time = (date now | format date "%Y-%m-%d %I-%M-%S")

  $"($env.HOME)/screenshots/screenshot ($current_time).png"
}

def screenshot [path: string] {
  niri msg action screenshot --path $path 
}

def "screenshot screen" [path: string] {
  niri msg action screenshot-screen --path $path
}

def "screenshot window" [path: string] {
  niri msg action screenshot-window --path $path
}

def upload-screenshot [path: string] {
  mut attempts = 0

  while not ($path | path exists) and $attempts < 5 {
    sleep 1sec
    $attempts += 1
  }

  storage upload $path (
    $path
    | str replace $"($env.HOME)/" ""
  )
}

def main [] {
  let path = (screenshot-path)

  screenshot $path
  upload-screenshot $path
}

def "main screen" [] {
  let path = (screenshot-path)

  screenshot screen $path
  upload-screenshot $path
}

def "main window" [] {
  let path = (screenshot-path)

  screenshot window $path
  upload-screenshot $path
}
