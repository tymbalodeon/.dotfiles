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
initialize *help:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/init.nu
    init {{ help }}

alias init := initialize

# List dependencies
dependencies *args:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/list-dependencies.nu
    list-dependencies {{ args }}

alias deps := dependencies

# Update dependencies
update *help:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/update.nu
    update {{ help }}

# Open Nix REPL with flake loaded
shell *host:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/shell.nu
    shell {{ host }}

# Run pre-commit hooks
check *args:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/check.nu
    check {{ args }}

# List available hosts
hosts *help:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/hosts.nu
    hosts {{ help }}

# Rebuild and switch to (or --test) a configuration
rebuild *args:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/rebuild.nu
    rebuild {{ args }}

# View remote repository
remote *browser:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/remote.nu
    remote {{ browser }}

# View issues
issue *args:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/issue.nu
    issue {{ args }}

# View repository analytics
stats *help:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/stats.nu
    stats {{ help }}

# Search project history
history *search_term:
    #!/usr/bin/env nu
    use {{ justfile_directory() }}/scripts/history.nu
    history {{ search_term }}
