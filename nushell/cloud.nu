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

# List available remotes
def "cloud list-remotes" [] {
    return (
        rclone listremotes
        | lines
        | str replace --regex ":$" ""
        | to text
    )
}

def get_path [remote: string path: string choose: bool] {
    return (
        if $choose {
            let remote = if (
                $remote
                | str ends-with ":"
            ) {
                $remote
            } else {
                $"($remote):"
            }

            rclone lsf $remote
            | fzf
        } else {
            $path
        }
    )
}

def get_remote_path [remote: string path: string choose: bool] {
    return $"($remote):(get_path $remote $path $choose)"
}

# List files on remote
def "cloud list" [
    remote: string # The name of the remote service
    path: string = "" # A path relative to <remote>:
    --choose # Choose a path interactively

] {
    return (rclone lsf (get_remote_path $remote $path $choose))
}

def get_local_path [remote: string path: string choose: bool] {
    return (
        $env.HOME
        | path join "rclone"
        | path join $remote
        | path join (get_path $remote $path $choose)
    )
}

# Download files from remote
def "cloud download" [
    remote: string # The name of the remote service
    path?: string # A path relative to <remote>:
    --choose # Choose a path interactively
] {
    let remote_path = (get_remote_path $remote $path $choose)
    let local_path = (get_local_path $remote $path $choose)

    return (rclone sync $remote_path (get_parent $local_path))
}

# Upload a file to remote
def "cloud upload" [
    remote: string # The name of the remote service
    path: string = "" # A path relative to <remote>:
    --choose # Choose a path interactively
] {
    let local_path = (get_local_path $remote $path $choose)

    if not ($local_path | path exists) {
        print ($path | path expand | path exists)

        return $"File not found: \"($path)\""
    }

    let remote_path = (get_remote_path $remote $path $choose)

    rclone copy $local_path (get_parent $remote_path)
}

# Download a file, open it in $EDITOR, and upload it after
def "cloud edit" [
    remote: string # The name of the remote service
    path: string = "" # A path relative to <remote>:
    --choose # Choose a path interactively
] {
    cloud download $remote $path
    ^$env.EDITOR (get_local_path $remote $path $choose)
    cloud upload $remote $path
}

# View, edit, and upload files to/from remote storage
def cloud [] {
    help cloud
}
