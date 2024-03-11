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

def rebuild [
    host?: # The target host configuration
] {
    let dotfiles = ($env.HOME | path join ".dotfiles");

    if (uname) == "Darwin" {
        home-manager switch --flake $dotfiles
    } 

    let host = if ($host | is-empty) {
        cat /etc/hostname | str trim
    } else {
        $host
    }

    sudo nixos-rebuild switch --flake $"($dotfiles)#($host)"
}

def --env z [
    directory?: # Limit the search to this directory
] {
    if ($directory | is-empty) {
        cd (
            fd --type directory --hidden . $env.HOME 
            | fzf --exact --reverse
        )  
    } else {
        cd (
            fd --type directory --hidden . $env.HOME 
            | fzf --exact --reverse --filter $directory | head -n 1
        )
    }
}

def --env Z [] {
    cd
}
