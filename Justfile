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
init *help:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/init.nu
    init {{ help }}

# List available hosts
hosts *help:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/hosts.nu
    hosts {{ help }}

# List dependencies
dependencies *host:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/list-dependencies.nu
    list-dependencies {{ host }}

# Update dependencies
update *help:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/update.nu
    update {{ help }}

# Run pre-commit hooks
check *args:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/check.nu
    check {{ args }}

# Open Nix REPL with flake loaded
shell *host:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/shell.nu
    shell {{ host }}
