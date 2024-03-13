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

def rebuild [
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

def themes [] {
    let config_file = ($env.HOME | path join ".config/tinty/config.toml")
    tinty install --config $config_file
    tinty apply (tinty list | fzf) --config $config_file
}
