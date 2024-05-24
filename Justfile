set shell := ["nu", "-c"]

@_help:
    nu ./scripts/help.nu

# Display the source code for a recipe
source recipe:
    #!/usr/bin/env nu
    source {{ justfile_directory() }}/scripts/source.nu
    src {{ recipe }}

# Search available `just` commands
[no-exit-message]
find *search_term:
    #!/usr/bin/env nu
    source {{ justfile_directory() }}/scripts/find.nu
    find {{ search_term }}

# Update dependencies
update *args:
    #!/usr/bin/env nu
    source {{ justfile_directory() }}/scripts/update.nu
    update-dependencies {{ args }}

# Run pre-commit hooks
check *hooks:
    #!/usr/bin/env nu
    source {{ justfile_directory() }}/scripts/check.nu
    check {{ hooks }}

# Open Nix REPL with flake loaded
shell *args:
    #!/usr/bin/env nu
    source {{ justfile_directory() }}/scripts/shell.nu
    shell {{ args }}
