# Open emacs, starting a client if not already running
def emacs [
    file? = "." # File or directory to open
    --quit # Stop the client
    --restart # Stop the client, then start a new one and open
    --force # Force the client to stop
] {
    if $quit or $restart {
        if $force {
            pkill -f emacs
        } else {
            emacsclient -e '(kill-emacs)'
        }
    }

    if not $quit {
        emacsclient -t -a "" $file
    }
}

# Interactively search for a directory and cd into it
def --env f [
    directory?: # Limit the search to this directory
] {
    if ($directory | is-empty) {
        cd (
            fd --type directory --hidden . $env.HOME 
            | fzf --exact
        )  
    } else {
        cd (
            fd --type directory --hidden . $env.HOME 
            | fzf --exact --filter $directory | head -n 1
        )
    }
}

# Switch to the current state of ~/.dotfiles
def switch [
    host?: # The target host configuration
] {
    let dotfiles = ($env.HOME | path join ".dotfiles");

    if (uname) == "Darwin" {
        home-manager switch --flake $dotfiles

        return
    } 

    let host = if ($host | is-empty) {
        cat /etc/hostname | str trim
    } else {
        $host
    }

    sudo nixos-rebuild switch --flake $"($dotfiles)#($host)"
}

# Set theme for various applications. See `--help` for options. When no options
# are passed, the theme will be temporarily applied to the shell.
def theme [
    theme? # The theme to set
    --helix # Set theme for helix
    --kitty # Set theme for kitty
    --shell # Set theme for shell (default)
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
        [$helix $kitty] 
        | any {|application| $application}
    ) {
        ["shell"]
    } else {
        mut applications = []

        if $helix { $applications = ($applications | append "helix") }
        if $kitty { $applications = ($applications | append "kitty") }
        if $shell { $applications = ($applications | append "shell") }

        $applications
    }

    if $shell { 
        (
            open ($nu.default-config-dir | path join "tinty.toml") 
            | upsert theme $theme 
            | save --force ($env.HOME | path join ".dotfiles/nushell/tinty.toml")
        )
    }

    for application in $applications {
        apply-theme $application $theme
    }
}
