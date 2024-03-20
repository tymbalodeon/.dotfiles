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

# Rebuild and switch to (or --test) the current configuration
def rebuild [
    host?: string # The target host configuration (auto-detected if not specified)
    --test # Apply the configuration without adding it to the boot menu
] {
    let host_name = if ($host | is-empty) {
        if (uname) == "Darwin" {
            "benrosen"
        } else {
            cat /etc/hostname
        }
    } else {
        $host
    }

    let dotfiles = ($env.HOME | path join ".dotfiles")
    let host = $"($dotfiles)#($host_name)"

    if (uname) == "Darwin" {
        home-manager switch --flake $host

        return
    }

    if $test {
        sudo nixos-rebuild test --flake $host
    } else {
        sudo nixos-rebuild switch --flake $host
    }
}
