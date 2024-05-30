def mount-remote [
    remote: string
    path: string
    mount_point: string
] {
    mkdir $mount_point
    rclone mount --daemon $"($remote):($path)" $mount_point
    echo $"\"($remote)\" mounted to: ($mount_point)"
}

def remove_empty_parents [dir: string] {
    mut dir = $dir

    while ($dir != $env.HOME) {
        rm $dir

        $dir = ($dir | path dirname)
    }
}

def unmount-remote [
    remote?: string
    mount_point?: path
] {
    if not ("~/rclone" | path exists) {
        return
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

    let base_mount_point = ($env.HOME | path join "rclone")


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
                mount-remote $remote_name $path $mount_point
            }
        }

        "unmount" => { unmount-remote $remote_name $mount_point }
    }
}
