[private]
@default:
    just help

# View full help text, or for a specific recipe
@help *args:
    .environments/generic/scripts/help.nu {{ args }}

# Check flake and run pre-commit hooks
@check *args:
    .environments/generic/scripts/check.nu {{ args }}

# Manage environments
@environment *args:
    .environments/generic/scripts/environment.nu {{ args }}

alias env := environment

# Search available `just` recipes
[no-exit-message]
@find-recipe *args:
    .environments/generic/scripts/find-recipe.nu {{ args }}

alias find := find-recipe

# View project history
@history *args:
    .environments/generic/scripts/history.nu {{ args }}

# View issues
@issue *args:
    .environments/generic/scripts/issue.nu {{ args }}

# View remote repository
@remote *args:
    .environments/generic/scripts/remote.nu  {{ args }}

# Find/replace
@replace *args:
    .environments/generic/scripts/replace.nu  {{ args }}

# View repository analytics
@stats *args:
    .environments/generic/scripts/stats.nu {{ args }}

# List TODO-style comments
@todo *args:
    .environments/generic/scripts/todo.nu {{ args }}

alias todos := todo

# Set helix theme
@theme *args:
    .environments/generic/scripts/theme.nu {{ args }}

# View the source code for a recipe
@view-source *args:
    .environments/generic/scripts/view-source.nu {{ args }}

alias src := view-source

[private]
@dot *args:
    just dotfiles {{ args }}

[private]
@hs *args:
    just haskell {{ args }}

mod dotfiles ".environments/dotfiles/Justfile"
mod haskell ".environments/haskell/Justfile"

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
