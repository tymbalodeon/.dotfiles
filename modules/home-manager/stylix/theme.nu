# View the currently built theme
def "theme" [] {
  help theme
}

# Preview theme
def "theme preview" [] {
  let theme = try {
    open ~/.local/state/stylix-theme
  }

  if ($theme | is-not-empty) {
    tinty info $"base16-($theme)"
  }
}
