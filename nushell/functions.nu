# Mount a remote storage service
def cloud [
    remote_name?: string # The name of the remote service (leave blank for all services)
    path?: string # A remote path to mount
    --mount # Mount the remote
    --unmount # Unmount the remote
] {
    let rclone_mount_point = ($env.HOME | path join "rclone")
    let all = ($remote_name | is-empty)

    let remotes = if $all {
        rclone listremotes | lines
    } else {
        [$"($remote_name):"]
    }

    for remote in $remotes {
        let include_path = ((not $all) and not ($path | is-empty))

        let remote_path = if $include_path {
            $"($remote)($path)"
        } else {
            $remote
        }

        mut mount_point = (
            $rclone_mount_point
            | path join ($remote | str replace ":" "")
        )

        if $include_path {
            $mount_point = ($mount_point | path join $path)
        }

        if $mount {
            mkdir $mount_point
            rclone mount --daemon $remote_path $mount_point
            echo $"\"($remote)\" mounted to: ($mount_point)"
        } else if $unmount {
            fusermount -u $mount_point out+err> /dev/null

            mut dir = $mount_point

            while ($dir != $env.HOME) and (ls $dir | is-empty) {
                rm $dir
                $dir = ($dir | path dirname)
            }
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
