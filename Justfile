set shell := ["nu", "-c"]

_help:
    #!/usr/bin/env nu

    (
        just --list
            --color always
            --list-heading (
                [
                    "Available recipes:"
                    "(run `<recipe> --help/-h` for more info)\n"
                ]
                | str join " "
            )
    )

# Display the source code for a recipe
source recipe *args="_":
    #!/usr/bin/env nu

    # Display the source code for a recipe. If no args are provided, display
    # the raw `just` code, otherwise display the code with the args provided
    # to `just` applied. Pass `""` as args to see the code when no args are
    # provided to a recipe, and to see the code with `just` variables expanded.
    def src [
        recipe: string # The recipe command
        ...args: string # Arguments to the recipe
    ] {
        if "_" in $args {
            just --show $recipe
        } else {
            just --dry-run $recipe $args
        }
    }

    src {{ recipe }} `{{ args }}`

# Search available `just` commands
[no-exit-message]
find *regex:
    #!/usr/bin/env nu

    # Search available `just` commands interactively, or by <regex>
    def find [
        regex?: string # Regex pattern to match
    ] {
        if ($regex | is-empty) {
            just --list | fzf
        } else {
            just | grep --color=always --extended-regexp $regex
        }
    }

    find {{ regex }}

# Run pre-commit hooks
check *args:
    #!/usr/bin/env nu

    # Run pre-commit hook by name, all hooks, or update all hooks
    def check [
        hook?: string # The hook to run
        --list # List all hook ids
        --update # Update all pre-commit hooks
    ] {
        if $list {
            print (
                grep id .pre-commit-config.yaml
                | str replace --all "- id:" ""
                | lines
                | str trim
                | sort
                | str join "\n"
            )

            return
        }

        if $update {
            pre-commit autoupdate

            return
        }

        if ($hook | is-empty) {
            pre-commit run --all-files
        } else {
            pre-commit run $hook --all-files
        }
    }

    check {{ args }}
