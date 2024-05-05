# Mount and unmount remote storage services
#
# Subcommands:
#    mount
#    unmount
def cloud [
    subcommand: string # Subcommand to run
    remote_name?: string # The name of the remote service (leave blank for all services)
    path?: string # A remote path to mount
] {
    if not ($subcommand | is-empty) and not (
      $subcommand in ["mount" "unmount"]
    ) {
        error make {
            msg: "Subcommand must be one of {mount, unmount}"
        }
    }

    def mount-remote [
        remote: string
        mount_point: string
    ] {
        mkdir $mount_point
        rclone mount --daemon $"($remote):($path)" $mount_point
        echo $"\"($remote)\" mounted to: ($mount_point)"
    }

    let base_mount_point = ($env.HOME | path join "rclone")

    def unmount-remote [
        remote?: string
        mount_point?: path
    ] {
        if not ("~/rclone" | path exists) {
            return
        }

        def remove_empty_parents [dir: string] {
            mut dir = $dir

            while ($dir != $env.HOME) {
                rm $dir

                $dir = ($dir | path dirname)
            }
        }

        if ($mount_point | is-empty) {
            let mount_points = (
                ls ~/rclone/
                | where type == "dir"
                | each {|remote| $remote | get name}
            )

            for mount_point in $mount_points {
                let mount_records = (mount | grep $mount_point)

                let path = if not ($mount_records | is-empty) {
                    $mount_records | split row " " | get 2
                } else {
                    ""
                }

                fusermount -u $path
                remove_empty_parents $path
            }
        } else {
            do --ignore-errors {
                fusermount -u $mount_point
            }

            remove_empty_parents $mount_point
        }
    }

    let mount_point = if ($remote_name | is-empty) {
        ""
    } else {
        $base_mount_point
        | path join $remote_name
        | path join $path
    }

    match $subcommand {
        "mount" => {
            if ($remote_name | is-empty) {
                print "Must provide remote name. Available remotes are:"
                print (
                    rclone listremotes
                    | lines
                    | each {|remote| $"    ($remote | str replace ":" "")"}
                    | str join "\n"
                )
            } else {
                mount-remote $remote_name $mount_point
            }
        }

        "unmount" => { unmount-remote $remote_name $mount_point }
    }
}

# Interactively search for a directory and cd into it
def --env f [
    directory?: # Limit the search to this directory
] {
    if ($directory | is-empty) {
        cd (
            fd --type directory --hidden . $env.HOME
            | fzf --exact --scheme path
        )
    } else {
        cd (
            fd --type directory --hidden . $env.HOME
            | fzf --exact --filter $directory --scheme path
            | head -n 1
        )
    }
}

# Rebuild and switch to (or --test) a configuration for (--hosts)
def rebuild [
    host?: string # The target host configuration (auto-detected if not specified)
    --hosts # List available hosts
    --test # Apply the configuration without adding it to the boot menu
] {
    def get_flake_path [attribute] {
        let dotfiles = ($env.HOME | path join ".dotfiles")

        $"($dotfiles)#($attribute)"
    }

    let is_darwin = (uname | get kernel-name) == "Darwin"

    if $hosts {
        let attribute = if $is_darwin {
            "homeConfigurations"
        } else {
            "nixosConfigurations"
        }

        return (
            nix eval (get_flake_path $attribute) --apply builtins.attrNames
            | str replace --all --regex '\[ | \]|"' ""
            | split row " "
            | str join "\n"
        )
    }

    let host_name = if ($host | is-empty) {
        if $is_darwin {
            "benrosen"
        } else {
            cat /etc/hostname | str trim
        }
    } else {
        $host
    }

    let host = get_flake_path $host_name

    if $is_darwin {
        home-manager switch --flake $host

        return
    }

    if $test {
        sudo nixos-rebuild test --flake $host
    } else {
        sudo nixos-rebuild switch --flake $host
    }
}
