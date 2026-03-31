export def get-themes [variant?: string] {
  let themes = (
    ^tinty list --json
    | from json
    | where system == base16
  )

  if $variant == dark {
    $themes
    | where variant == dark
  } else if $variant == light {
    $themes
    | where variant == light
  } else {
    $themes
  }
}

export def get-theme [theme: string] {
  let themes = (get-themes)

  let theme = if ($theme | str starts-with base16-) {
    $themes
    | where id == ($theme | str downcase)
  } else {
    let theme_by_name = (
      $themes
      | where name == $theme
    )

    if ($theme_by_name | is-empty) {
      $themes
      | where id == $"base16-($theme | str downcase)"
    } else {
      $theme_by_name
    }
  }

  if ($theme | is-empty) {
    return
  }

  $theme
  | first
  | get id
}

export def main [theme: string dark: bool light: bool] {
  let theme = if ($theme | is-empty) {
    select-theme (get-variant $dark $light)
  } else {
    $theme
  }

  let theme = (get-theme $theme)

  if ($theme | is-empty) {
    return
  }

  tinty info $theme
}

