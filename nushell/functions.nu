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
# are passed, the theme will be applied to all supported applications.
def set-theme [
    theme? # The theme to set
    --helix # Set theme for helix
    --kitty # Set theme for kitty
] {
    let config_dir = ($env.HOME | path join ".config/tinty")

    def apply-theme [application theme] {
        let config_file = ($config_dir | path join $"($application).toml")
        tinty --config $config_file install
        tinty --config $config_file apply $theme
    }

    let theme = if ($theme | is-empty) {
        tinty list | fzf
    } else {
        $theme
    }

    mut applications = []
    let all = not ([$helix $kitty] | any {|application| $application})

    if $all or $helix { $applications = ($applications | append "helix") }
    if $all or $kitty { $applications = ($applications | append "kitty") }

    for application in $applications {
        apply-theme $application $theme
    }
}
