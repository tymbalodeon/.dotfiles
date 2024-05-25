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

# Set theme for various applications. See `--help` for options. When no options
# are passed, the theme will be temporarily applied to the shell immediately.
# Otherwise, the configuration must be rebuilt with `rebuild`, configurations
# reloaded, and/or services restarted in order for changes to be applied.
export def main [
    theme?: string # The theme to set
    --all # Set all themes
    --fzf # Set theme for fzf
    --helix # Set theme for helix
    --kitty # Set theme for kitty
    --shell # Set (persistent) theme for shell
    --update # Update the themes
] {
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

    let none = not (
        [$all $fzf $helix $kitty]
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
        if ($all or $shell) { $applications = ($applications | append "shell") }

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
