def current-theme [] {
  try {
    open ~/.local/state/theme
  }
}

# View the currently built theme
def theme [] {
  current-theme
}

def info [theme: string] {
  tinty info $"base16-($theme)"
}

# Preview theme
def "theme preview" [] {
  let theme = (current-theme)

  if ($theme | is-not-empty) {
    try {
      info $theme
    } catch {
      tinty update out> /dev/null
      info $theme
    }
  }
}
