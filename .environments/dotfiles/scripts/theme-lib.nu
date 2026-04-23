def "tinty list" [] {
  try {
    ^tinty list out+err> /dev/null
  } catch {
    tinty install
  }

  ^tinty list --json
  | from json
  | where {$in.system == base16}
}

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

def available-themes [] {
  let state_path = ($env.XDG_STATE_HOME | path join stylix-available-themes.txt)

  let themes = try {
    open $state_path
  } catch {
    let themes = (
      gh api --jq ".[].name" /repos/tinted-theming/schemes/contents/base16
      | str replace --all .yaml ""
    )

    $themes
    | save --force $state_path
  }

  $themes
  | lines
}

def format-theme-name [theme: string] {
  let theme = ($theme | str downcase | str replace base16- "")

  try {
    available-themes
    | where $it == $theme
    | first
  }
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
    } catch {
      exit
    }
  }
}

export def theme-preview [
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

def get-env-value [values: table<key: string, value: string> key: string] {
  try {
    $values
    | where key == $key
    | get value
    | first
  }
}

export def get-env-values [] {
  try {
    let values = (open ../.env | parse "{key}={value}")
    let variant = (get-env-value $values DOTFILES_RANDOM_THEME_VARIANT)
    let random_theme = (get-env-value $values DOTFILES_RANDOM_THEME)

    {
      dark_theme: (($variant | str downcase) == dark)
      light_theme: (($variant | str downcase) == light)

      random_theme: (
        if ($random_theme | is-empty) {
          false
        } else {
          $random_theme
        }
      )
    }
  } catch {
    {
      dark_theme: false
      light_theme: false
      random_theme: false
    }
  }
}

export def stylix-theme-path [] {
  $env.XDG_STATE_HOME
  | path join stylix-theme
}

export def get-built-theme [] {
  try {
    open (stylix-theme-path)
    | str trim
  }
}

export def set-built-theme [theme?: string] {
  if ($theme | is-not-empty) {
    $theme
    | save --force (stylix-theme-path)
  }
}
