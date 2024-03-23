# Mount a remote storage service
#
# Subcommands:
#    mount
#    unmount
def cloud [
    subcommand: string # Subcommand to run
    remote_name?: string # The name of the remote service (leave blank for all services)
    path = "" # A remote path to mount
] {
    def mount [
        remote: string
        mount_point: string
    ] {
        mkdir $mount_point
        rclone mount --daemon $"($remote)($path)" $mount_point
        echo $"\"($remote)\" mounted to: ($mount_point)"
    }

    def unmount [
        remote: string
        mount_point: path
    ] {
        do --ignore-errors {
            fusermount -u $mount_point out+err> /dev/null
        }

        mut dir = $mount_point

        while ($dir != $env.HOME) {
            if ($dir | path exists) and (ls $dir | is-empty) {
                rm -rf $dir
            }

            $dir = ($dir | path dirname)
        }
    }

    let rclone_mount_point = ($env.HOME | path join "rclone")
    let all = ($remote_name | is-empty)

    let remotes = if $all {
        rclone listremotes | lines
    } else {
        [$"($remote_name):"]
    }

    for remote in $remotes {
        mut mount_point = (
            $rclone_mount_point
            | path join ($remote | str replace ":" "")
            | path join $path
        )

        match $subcommand {
            "mount" => { mount $remote $mount_point }
            "unmount" => { unmount $remote $mount_point }
        }
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
            cat /etc/hostname | str trim
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
