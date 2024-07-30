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

def cloud [
    path?: string # A remote path to mount
    --edit # Edit file on remote
    --list # List files on remote
    --remote = "dropbox" # The name of the remote service
    --remotes # List available remotes
] {
    if $remotes or ($path | is-empty) {
        return (rclone listremotes)
    } 

    let remote_path = $"($remote):($path)"

    if $list {
        return (rclone lsf $remote_path)
    }

    if $edit {
        let local_path = (
            $env.HOME 
            | path join "rclone" 
            | path join $remote
            | path join $path
        )

        let local_path_parent = (get_parent $local_path)
        let remote_path_parent = (get_parent $remote_path)

        mkdir $local_path_parent
        rclone sync $remote_path $local_path_parent
        hx $local_path
        rclone copy $local_path $remote_path
    }
}
