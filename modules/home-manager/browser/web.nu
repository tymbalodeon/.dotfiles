# Show the default browser
def "web default" [] {
 try {
    open ($env.HOME | ".config/dotfiles/web.toml")
    | get default-browser
  } catch {
    "w3m"
  }
}

# Browse the web
def --wrapped web [...args: string] {
  run-external (web default) ...$args
}

# List available web browsers
def "web list browsers" [] {
  [
    browsh
    chawan
    w3m
  ]
  | to text --no-newline
}
