def run-theme [
    application: string
    theme?: string
    --update
] {
    let config_file = (
        ($env.HOME | path join ".config/tinty")
        | path join $"($application).toml"
    )

    tinty --config $config_file install out> /dev/null

    if $update {
        tinty --config $config_file update
    } else {
        tinty --config $config_file apply $theme
    }
}

def filter_themes [themes: string type: number] {
    let base = $"base($type)"
    return (
        $themes
        | lines
        | filter {|theme| $base in $theme}
        | each {|theme| $theme | str replace $"($base)-" ""}
        | to text
    )
}

# Set theme for various applications. See `--help` for options. When no options
# are passed, the theme will be temporarily applied to the shell immediately.
# Otherwise, the configuration must be rebuilt, configurations reloaded, and/or
# services restarted in order for changes to be applied.
def theme [
    theme?: string # The theme to set
    --all # Set all themes
    --base16 # Select only base-16 theme(s)
    --base24 # Select only base-24 theme(s)
    --fzf # Set theme for fzf
    --helix # Set theme for helix
    --kitty # Set theme for kitty
    --list # List available themes
    --mako # Set theme for mako
    --preview # View colors for $theme
    --rofi # Set theme for rofi
    --shell # Set (persistent) theme for shell
    --waybar # Set theme for waybar
    --update # Update the themes
] {
    if $list {
        let themes = (tinty list)

        if $base16 {
            return (filter_themes $themes 16)            
        } else if $base24 {
            return (filter_themes $themes 24)            
        } else {
            mut themes_and_bases = {}

            for theme in ($themes | lines) {
                let base = ($theme | split row "-" | first)
                let theme = ($theme | str replace $"($base)-" "")

                if $theme in ($themes_and_bases | columns) {
                    let bases = (
                        $themes_and_bases 
                        | get $theme 
                        | append $base 
                        | sort 
                        | str join ", "
                    )

                    $themes_and_bases = ($themes_and_bases | upsert $theme $bases)
                } else {
                    $themes_and_bases = ($themes_and_bases | insert $theme $base)
                }
            }

            return (
                $themes_and_bases
                | transpose theme bases
                | sort-by theme
                | table --index false
            )
        }
    }

    if ($theme | is-empty) and $preview {
        let themes = (tinty list)

        let themes = if $base16 {
            $themes | rg base16
        } else if $base24 {
            $themes | rg base24
        } else {
            $themes
        }

        return ($themes | fzf --preview 'tinty info {}')
    }

    let theme = if ((not $update) and ($theme | is-empty)) {
        tinty list | fzf | str trim
    } else {
        if ($theme | find --regex "base\\d{2}-" | is-empty) {
            $"base16-($theme)"
        } else {
            $theme
        }
    }

    if (not $update) and ($theme | is-empty) {
        return
    }

    if $preview {
        return (tinty info $theme)
    }

    let none = not (
        [$all $fzf $helix $kitty $mako $rofi $waybar]
        | any {|application| $application}
    )

    let $all = if $update and $none {
        true
    } else {
        $all
    }

    let applications = if (not $update) and $none {
        ["shell"]
    } else {
        mut applications = []

        if ($all or $fzf) { $applications = ($applications | append "fzf") }
        if ($all or $helix) { $applications = ($applications | append "helix") }
        if ($all or $kitty) { $applications = ($applications | append "kitty") }
        if ($all or $mako) { $applications = ($applications | append "mako") }
        if ($all or $rofi) { $applications = ($applications | append "rofi") }
        if ($all or $shell) { $applications = ($applications | append "shell") }
        if ($all or $waybar) { $applications = ($applications | append "waybar") }

        $applications
    }

    if (not $update) and ($all or $shell) {
        let themes_file = (
            $env.HOME | path join ".dotfiles/nushell/themes.toml"
        )

        (
            open $themes_file
            | upsert shell_theme $theme
            | save --force $themes_file
        )
    }

    for application in $applications {
        if $update {
            run-theme $application --update
        } else {
            run-theme $application $theme
        }
    }
}
