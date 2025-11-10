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
            | fzf --exact --where $directory --scheme path
            | head -n 1
        )
    }
}
