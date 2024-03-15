# Set theme for various applications. See `--help` for options. When no options
# are passed, the theme will be temporarily applied to the shell immediately.
# Otherwise, the configuration must be rebuilt with `rebuild`, configurations
# reloaded, and/or services restarted in order for changes to be applied.
def theme [
    theme?: string # The theme to set
    --all # Set all themes
    --fzf # Set theme for fzf
    --helix # Set theme for helix
    --kitty # Set theme for kitty
    --mako # Set theme for mako
    --rofi # Set theme for rofi
    --shell # Set (persistent) theme for shell
] {
    let config_dir = ($env.HOME | path join ".config/tinty")

    def apply-theme [application theme] {
        let config_file = ($config_dir | path join $"($application).toml")
        tinty --config $config_file install out> /dev/null
        tinty --config $config_file apply $theme
    }

    let theme = if ($theme | is-empty) {
        tinty list | fzf | str trim
    } else {
        $theme
    }

    let applications = if not (
        [$all $fzf $helix $kitty $mako $rofi] 
        | any {|application| $application}
    ) {
        ["shell"]
    } else {
        mut applications = []

        if ($all or $fzf) { $applications = ($applications | append "fzf") }
        if ($all or $helix) { $applications = ($applications | append "helix") }
        if ($all or $kitty) { $applications = ($applications | append "kitty") }
        if ($all or $mako) { $applications = ($applications | append "mako") }
        if ($all or $rofi) { $applications = ($applications | append "rofi") }
        if ($all or $shell) { $applications = ($applications | append "shell") }

        $applications
    }

    if ($all or $shell) { 
        (
            open ($nu.default-config-dir | path join "themes.toml") 
            | upsert theme $theme 
            | save --force ($env.HOME | path join ".dotfiles/nushell/themes.toml")
        )
    }

    for application in $applications {
        apply-theme $application $theme
    }
}
