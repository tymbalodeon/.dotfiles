use ($nu.default-config-dir | path join "colors.nu") *
use ($nu.default-config-dir | path join "theme.nu") get_theme

$env.config = {
    color_config: (get_theme)

    cursor_shape: {
        vi_insert: line        
        vi_normal: block
    }

    datetime_format: { normal: '%A, %B %d, %Y %H:%M:%S' }
    edit_mode: vi 

    hooks: {
        env_change: {
            PWD: [
                {||
                    if (which direnv | is-empty) {
                        return
                    }

                    direnv export json | from json | default {} | load-env
                }
            ] 
        }
    }

    show_banner: false 
}

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

alias cat = bat --style plain --theme gruvbox-dark
alias chedit = chezmoi edit --apply
alias dig = dog
alias grep = rg
alias just = just --unstable
alias l = ls --long
alias la = ls --long --all
alias lsa = ls --all
alias ping = gping
alias sed = sd
alias themes = kitty +kitten themes
alias top = btm
alias treei = eza --tree --level=2
alias tree = treei --git-ignore
alias treea = treei --all
alias vim = nvim
