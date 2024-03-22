# Mount a remote storage service
def cloud [ 
    remote: string # The name of the remote service
    --mount # Mount the remote
    --unmount # Unmount the remote
] {
    let rclone_mount_point = ($env.HOME | path join "rclone")
    let mount_point = ($rclone_mount_point | path join $remote)

    if $mount {
        mkdir $mount_point
        rclone mount --daemon $"($remote):" $mount_point
        echo $"\"($remote)\" mounted to: ($mount_point)"
    } else if $unmount {
        fusermount -u $mount_point out+err> /dev/null
        rm -rf $mount_point

        if (ls $rclone_mount_point | is-empty) {
            rm -rf $rclone_mount_point           
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
