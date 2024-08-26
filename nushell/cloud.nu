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

def get_remote_path [--path: string --remote: string ] {
    return $"($remote):($path)"
}

# List files on remote
def "cloud list" [
    remote: string # The name of the remote service
    path: string = "" # A path relative to <remote>:

] {
    let remote_path = (get_remote_path --path $path --remote $remote)

    return (rclone lsf $remote_path)
}

def get_local_path [--path: string --remote: string] {
    return (
        $env.HOME
        | path join "rclone"
        | path join $remote
        | path join $path
    )
}

# Download files from remote
def "cloud download" [
    --path: string = "" # A path relative to <remote>:
    --remote: string = "dropbox" # The name of the remote service
] {
    let remote_path = (get_remote_path --path $path --remote $remote)
    let local_path = (get_local_path --path $path --remote $remote)

    return (rclone sync $remote_path (get_parent $local_path))
}

# Upload a file to remote
def "cloud upload" [
    --path: string = "" # A path relative to <remote>:
    --remote: string = "dropbox" # The name of the remote service
] {
    let local_path = (get_local_path --path $path --remote $remote)

    if not ($local_path | path exists) {
        print ($path | path expand | path exists)

        return $"File not found: \"($path)\""
    }

    let remote_path = (get_remote_path --path $path --remote $remote)

    rclone copy $local_path (get_parent $remote_path)
}

# Download a file, open it in $EDITOR, and upload it after
def "cloud edit" [
    --path: string = "" # A path relative to <remote>:
    --remote: string = "dropbox" # The name of the remote service
] {
    cloud download --path $path --remote $remote
    ^$env.EDITOR (get_local_path --path $path --remote $remote)
    cloud upload --path $path --remote $remote
}

# View, edit, and upload files to/from remote storage
def cloud [] {
    help cloud
}
