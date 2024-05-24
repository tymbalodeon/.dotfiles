set shell := ["nu", "-c"]

@_help:
    nu ./scripts/help.nu

# View the source code for a recipe
view-source recipe:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/view-source.nu
    view-source {{ recipe }}

# Search available `just` recipes
[no-exit-message]
find-recipe *search_term:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/find-recipe.nu
    find-recipe {{ search_term }}

# Initialize direnv environment
init *args:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/init.nu
    init {{ args }}

# Update dependencies
update *args:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/update-dependencies.nu
    update-dependencies {{ args }}

# Run pre-commit hooks
check *args:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/check.nu
    check {{ args }}

# Open Nix REPL with flake loaded
shell *args:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/shell.nu
    shell {{ args }}
