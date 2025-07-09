set working-directory := "../.."

# View help text
@help *args:
    .environments/scripts/dotfiles/help.nu {{ args }}

# Check configuration flake
[working-directory("./configuration")]
@check *args:
    ../.environments/scripts/dotfiles/check.nu {{ args }}

# Run `prune` and `optimise`
@clean *args:
    .environments/scripts/dotfiles/clean.nu {{ args }}

# View the diff between hosts
[no-cd]
@diff *args:
    .environments/scripts/dotfiles/diff.nu {{ args }}

# List configuration files
[no-cd]
@files *args:
    .environments/scripts/dotfiles/files.nu {{ args }}

# View generations
@generations *help:
    .environments/scripts/dotfiles/generations.nu {{ help }}

# List available configurations
@configurations *args:
    .environments/scripts/dotfiles/configurations.nu {{ args }}

alias configs := configurations

# List flake inputs
[working-directory("./configuration")]
@inputs *help:
    ../.environments/scripts/dotfiles/inputs.nu {{ help }}

# Replace identical files in the Nix store by hard links
@optimise *help:
    .environments/scripts/dotfiles/optimise.nu {{ help }}

# Collect garbage and remove old generations
@prune *args:
    .environments/scripts/dotfiles/prune.nu {{ args }}

# Rebuild and switch to (or --test) a configuration
[working-directory("./configuration")]
@rebuild *args:
    ../.environments/scripts/dotfiles/rebuild.nu {{ args }}

# Rollback to a previous generation
[macos]
@rollback *id:
    .environments/scripts/dotfiles/rollback.nu {{ id }}

# Open Nix REPL with flake loaded
@shell *help:
    .environments/scripts/dotfiles/shell.nu {{ help }}

# Update dependencies
[working-directory("./configuration")]
@update *inputs:
    ../.environments/scripts/dotfiles/update.nu {{ inputs }}
