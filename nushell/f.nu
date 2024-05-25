# Interactively search for a directory and cd into it
export def --env main [
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
