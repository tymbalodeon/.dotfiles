# View help text
@help *recipe:
    ./scripts/help.nu {{ recipe }}

# Check flake and run pre-commit hooks
@check *args:
    ./scripts/check.nu {{ args }}

# List dependencies
@dependencies *args:
    ./scripts/dependencies.nu {{ args }}

alias deps := dependencies

# Manage environments
@environment *args:
    ./scripts/environment.nu {{ args }}

alias env := environment

# Search available `just` recipes
[no-cd]
[no-exit-message]
@find-recipe *search_term:
    ./scripts/find-recipe.nu {{ search_term }}

alias find := find-recipe

# View project history
[no-cd]
@history *args:
    ./scripts/history.nu {{ args }}

# View issues
@issue *args:
    ./scripts/issue.nu {{ args }}

# Create a new release
@release *preview:
    ./scripts/release.nu  {{ preview }}

# View remote repository
@remote *web:
    ./scripts/remote.nu  {{ web }}

# View repository analytics
@stats *help:
    ./scripts/stats.nu {{ help }}

# Run tests
@test *args:
    ./scripts/test.nu {{ args }}

# View the source code for a recipe
[no-cd]
@view-source *recipe:
    ./scripts/view-source.nu {{ recipe }}

alias src := view-source

mod dotfiles "just/dotfiles.just"

# alias for `dotfiles clean`
@clean *all:
    just dotfiles clean {{ all }}

# alias for `dotfiles diff`
@diff *args:
    just dotfiles diff {{ args }}

# alias for `dotfiles files`
@files *configuration:
    just dotfiles files {{ configuration }}

# alias for `dotfiles generations`
@generations *help:
    just dotfiles generations {{ help }}

# alias for `dotfiles hosts`
@hosts *help:
    just dotfiles hosts {{ help }}

# alias for `dotfiles inputs`
@inputs *help:
    just dotfiles inputs {{ help }}

# alias for `dotfiles optimise`
@optimise *help:
    just dotfiles optimise {{ help }}

# alias for `dotfiles prune`
@prune *args:
    just dotfiles prune {{ args }}

# alias for `dotfiles rebuild`
@rebuild *args:
    just dotfiles rebuild {{ args }}

# alias for `dotfiles rollback`
@rollback *id:
    just dotfiles rollback {{ id }}

# alias for `dotfiles shell`
@shell *host:
    just dotfiles shell {{ host }}

# alias for `dotfiles update`
@update *help:
    just dotfiles update {{ help }}
