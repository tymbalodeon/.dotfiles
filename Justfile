[private]
@default:
    just help

# View full help text, or for a specific recipe
@help *args:
    ./scripts/help.nu {{ args }}

# Check flake and run pre-commit hooks
@check *args:
    ./scripts/check.nu {{ args }}

# Manage environments
@environment *args:
    ./scripts/environment.nu {{ args }}

alias env := environment

# Search available `just` recipes
[no-exit-message]
@find-recipe *args:
    ./scripts/find-recipe.nu {{ args }}

alias find := find-recipe

# View project history
@history *args:
    ./scripts/history.nu {{ args }}

# View issues
@issue *args:
    ./scripts/issue.nu {{ args }}

# View remote repository
@remote *args:
    ./scripts/remote.nu  {{ args }}

# Find/replace
@replace *args:
    ./scripts/replace.nu  {{ args }}

# View repository analytics
@stats *args:
    ./scripts/stats.nu {{ args }}

# List TODO-style comments
@todo *args:
    ./scripts/todo.nu {{ args }}

alias todos := todo

# Set helix theme
@theme *args:
    ./scripts/theme.nu {{ args }}

# View the source code for a recipe
@view-source *args:
    ./scripts/view-source.nu {{ args }}

alias src := view-source

mod dotfiles "just/dotfiles.just"
mod haskell "just/haskell.just"

alias clean := dotfiles::clean
alias configs := dotfiles::configurations
alias configurations := dotfiles::configurations
alias diff := dotfiles::diff
alias files := dotfiles::files
alias generations := dotfiles::generations
alias inputs := dotfiles::inputs
alias optimise := dotfiles::optimise
alias prune := dotfiles::prune
alias rebuild := dotfiles::rebuild
alias shell := dotfiles::shell
alias update := dotfiles::update
