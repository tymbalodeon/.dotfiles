# View help text
@help *recipe:
    ../scripts/dotfiles/help.nu {{ recipe }}

# Check configuration flake
[working-directory: "../configuration"]
@check *help:
    ../scripts/dotfiles/check.nu {{ help }}

# Run `prune` and `optimise`
@clean *all:
    ../scripts/dotfiles/clean.nu {{ all }}

# View the diff between hosts
[no-cd]
@diff *args:
    ./scripts/dotfiles/diff.nu {{ args }}

# List configuration files
[no-cd]
@files *configuration:
    ./scripts/dotfiles/files.nu {{ configuration }}

# View generations
@generations *help:
    ../scripts/dotfiles/generations.nu {{ help }}

# List available hosts
[no-cd]
@hosts *help:
    ./scripts/dotfiles/hosts.nu {{ help }}

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

# Update README command output
[no-cd]
[private]
@readme *help:
    ./scripts/dotfiles/readme.nu {{ help }}

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
@shell *host:
    ./scripts/dotfiles/shell.nu {{ host }}

# Update dependencies
[no-cd]
@update *help:
    ./scripts/dotfiles/update.nu {{ help }}
