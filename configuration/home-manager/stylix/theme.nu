def main [] {}

# Preview theme
def "main preview" [] {
  let theme = try {
    open ~/.local/state/stylix-theme
  }

  if ($theme | is-not-empty) {
    tinty info $theme
  }
}
