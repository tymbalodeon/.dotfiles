def screenshots-directory [] {
  $"($env.HOME)/screenshots"
}

def screenshot-path [] {
  mkdir (screenshots-directory)

  let current_time = (date now | format date "%Y-%m-%d %I-%M-%S")

  $"(screenshots-directory )/screenshot ($current_time).png"
}

def take-screenshot [path: string] {
  niri msg action screenshot --path $path 
}

def "take-screenshot screen" [path: string] {
  niri msg action screenshot-screen --path $path
}

def "take-screenshot window" [path: string] {
  niri msg action screenshot-window --path $path
}

def upload-screenshot [path: string] {
  job spawn {
    mut attempts = 0

    while not ($path | path exists) and $attempts < 5 {
      sleep 1sec
      $attempts += 1
    }

    storage upload $path (
      $path
      | str replace $"($env.HOME)/" ""
    )
  } out> /dev/null
}

def main [] {
  let path = (screenshot-path)

  take-screenshot $path
  upload-screenshot $path
}

def "main screen" [] {
  let path = (screenshot-path)

  take-screenshot screen $path
  upload-screenshot $path
}

def "main window" [] {
  let path = (screenshot-path)

  take-screenshot window $path
  upload-screenshot $path
}

def screenshot [] {
  main
}

def "screenshot clear" [] {
  rm --force --recursive (screenshots-directory)
}

def "screenshot screen" [] {
  main screen
}

def "screenshot window" [] {
  main window
}
