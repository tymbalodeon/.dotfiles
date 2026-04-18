def get-themes [variant?: string] {
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

def format-theme-name [theme: string] {
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

def get-variant [dark?: bool light?: bool] {
  if $dark {
    "dark"
  } else if $light {
    "light"
  } else {
    null
  }
}

def get-random-theme [variant?: string] {
  let themes = (get-themes $variant)

  let theme = (
    $themes
    | get (random int 0..($themes | enumerate | get index | last))
    | get name
  )

  format-theme-name $theme
}

# TODO: allow displaying name and selecting id
def select-theme [variant?: string] {
  let themes = (get-themes $variant)

  let theme_name = (
    $themes
    | get name
    | to text
    | fzf
        --preview $"
          let theme = \(
            tinty list --json
            | from json
            | where name == {}
            | first
            | get id
          \)

          tinty info $theme
        "
        --with-shell "nu -c"
  )

  $themes
  | where name == $theme_name
  | first
  | get id
}

export def get-theme [dark: bool light: bool random: bool theme?: string] {
  if ($theme | is-not-empty) {
    format-theme-name $theme
  } else if $random {
    get-random-theme (get-variant $dark $light)
  } else {
    try {
      select-theme (get-variant $dark $light)
    }
  }
}

export def main [
  dark: bool
  light: bool
  random: bool
  theme?: string
] {
  let theme = (get-theme $dark $light $random $theme)

  if ($theme | is-empty) {
    return
  }

  tinty info $theme
}

export def get-stylix-theme-name [theme: string] {
  $theme
  | str replace base16- ""
}

