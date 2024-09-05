set unstable := true

# View help text
@help *recipe:
    ./scripts/help.nu {{ recipe }}

# View file annotated with version control information
[no-cd]
@annotate *filename:
    ./scripts/annotate.nu {{ filename }}

# Check flake and run pre-commit hooks
@check *args:
    ./scripts/check.nu {{ args }}

# Run `prune` and `optimise`
@clean *all:
    ./scripts/clean.nu {{ all }}

# List dependencies
@deps *args:
    ./scripts/deps.nu {{ args }}

# View the diff between hosts
@diff *args:
    ./scripts/diff.nu {{ args }}

# View the diff between environments
@diff-env *args:
    ./scripts/diff-env.nu {{ args }}

# Search available `just` recipes
[no-exit-message]
@find-recipe *search_term:
    ./scripts/find-recipe.nu {{ search_term }}

# View generations
@generations *help:
    ./scripts/generations.nu {{ help }}

# View project history
[no-cd]
@history *args:
    ./scripts/history.nu {{ args }}

# List available hosts
@hosts *help:
    ./scripts/hosts.nu {{ help }}

# Initialize direnv environment
@init *help:
    ./scripts/init.nu {{ help }}

# View issues
@issue *args:
    ./scripts/issue.nu {{ args }}

# Replace identical files in the Nix store by hard links
@optimise *help:
    ./scripts/optimise.nu {{ help }}

# Collect garbage and remove old generations
@prune *args:
    ./scripts/prune.nu {{ args }}

# Update README command output
[private]
@readme *help:
    ./scripts/readme.nu {{ help }}

# Rebuild and switch to (or --test) a configuration
@rebuild *args:
    ./scripts/rebuild.nu {{ args }}

# Create a new release
@release *args:
    ./scripts/release.nu  {{ args }}

# View remote repository
@remote *web:
    ./scripts/remote.nu  {{ web }}

# Rollback to a previous generation
[macos]
@rollback *id:
    ./scripts/rollback.nu {{ id }}

# Open Nix REPL with flake loaded
@shell *host:
    ./scripts/shell.nu {{ host }}

# View repository analytics
@stats *help:
    ./scripts/stats.nu {{ help }}

# Update dependencies
@update-deps *help:
    ./scripts/update-deps.nu {{ help }}

# View the source code for a recipe
[no-cd]
@view-source *recipe:
    ./scripts/view-source.nu {{ recipe }}
