def get_parent [path: string] {
    if (
        $path 
        | rg '\.[a-zA-Z]+$' 
        | complete
    ).exit_code == 0 {
        return (
            $path 
            | path dirname
        )
    } else {
        return $path
    }
}

# View, edit, and upload files to/from remote storage
def cloud [
    path?: string # A path relative to <remote>:
    --download # Download file from remote
    --edit # Edit file on remote
    --list # List files on remote
    --remote = "dropbox" # The name of the remote service
    --remotes # List available remotes
    --upload # Upload file to remote
] {
    if $remotes or ($path | is-empty) {
        return (rclone listremotes)
    } 

    let remote_path = $"($remote):($path)"

    if $list {
        return (rclone lsf $remote_path)
    }

    let local_path = (
        $env.HOME 
        | path join "rclone" 
        | path join $remote
        | path join $path
    )

    let local_path_parent = (get_parent $local_path)
    let remote_path_parent = (get_parent $remote_path)

    if $download or $edit {
        return (rclone sync $remote_path $local_path_parent)
    }

    if $edit {
        hx $local_path
    }

    if $upload and not ($local_path | path exists) {
        print ($path | path expand | path exists)
        return $"File not found: \"($path)\""
    }

    rclone copy $local_path $remote_path_parent
}
