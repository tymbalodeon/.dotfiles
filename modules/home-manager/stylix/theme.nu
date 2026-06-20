def current-theme [] {
  try {
    open ~/.local/state/stylix-theme
  }
}

# View the currently built theme
def "theme" [] {
  current-theme
}

# Preview theme
def "theme preview" [] {
  let theme = (current-theme)

  if ($theme | is-not-empty) {
    tinty info $"base16-($theme)"
  }
}
