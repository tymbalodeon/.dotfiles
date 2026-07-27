def config-file [] {
  $env.HOME
  | ".config/dotfiles/web.toml"
}

# Show the default browser
def "web default" [] {
 try {
    open (config-file)
    | get default-browser
  } catch {
    "w3m"
  }
}

def available-browsers [] {
  [
    browsh
    chawan
    w3m
  ]
}

# Set the default browser
def "web default set" [browser: string] {
  let browser = ($browser | str lowercase)

  if ($browser | not-in (available-browsers)) {
    error make {
      msg: $"unrecognized browser: `($browser)`. See `web list browsers` for available browsers."
    }
  }

  let config_file = (config-file)

  mkdir ($config_file | path dirname)

  {default-browser: $browser}
  | save --force ($config_file)
}

# Browse the web
def --wrapped web [...args: string] {
  # TODO: allow passing `--browser` to select a different browser than the default
  
  run-external (web default) ...$args
}

# List available web browsers
def "web list browsers" [] {
  available-browsers
  | to text --no-newline
}
