# View help text
@help *args:
    ../scripts/dotfiles/help.nu {{ args }}

# Check configuration flake
[working-directory: "../configuration"]
@check *args:
    ../scripts/dotfiles/check.nu {{ args }}

# Run `prune` and `optimise`
@clean *args:
    ../scripts/dotfiles/clean.nu {{ args }}

# View the diff between hosts
[no-cd]
@diff *args:
    ./scripts/dotfiles/diff.nu {{ args }}

# List configuration files
[no-cd]
@files *args:
    ./scripts/dotfiles/files.nu {{ args }}

# View generations
@generations *help:
    ../scripts/dotfiles/generations.nu {{ help }}

# List available configurations
[no-cd]
@configurations *args:
    ./scripts/dotfiles/configurations.nu {{ args }}

alias configs := configurations

# List flake inputs
[working-directory: "../configuration"]
@inputs *help:
    ../scripts/dotfiles/inputs.nu {{ help }}

# Replace identical files in the Nix store by hard links
@optimise *help:
    ../scripts/dotfiles/optimise.nu {{ help }}

# Collect garbage and remove old generations
@prune *args:
    ../scripts/dotfiles/prune.nu {{ args }}

# Rebuild and switch to (or --test) a configuration
[working-directory: "../configuration"]
@rebuild *args:
    ../scripts/dotfiles/rebuild.nu {{ args }}

# Rollback to a previous generation
[macos]
@rollback *id:
    ../scripts/dotfiles/rollback.nu {{ id }}

# Open Nix REPL with flake loaded
[no-cd]
@shell *help:
    ./scripts/dotfiles/shell.nu {{ help }}

# Update dependencies
[working-directory: "../configuration"]
@update *inputs:
    ../scripts/dotfiles/update.nu {{ inputs }}
